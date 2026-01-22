
// src/api/services/supabaseDatabaseService.ts
import { supabase, TABLES } from '../config/supabase';

/**
 * SERVICE SUPABASE DATABASE
 * Remplace firestoreService pour toutes les opérations de base de données
 */

export const supabaseDatabaseService = {
  /**
   * Récupère tous les documents d'une table
   */
  getCollection: async <T = any>(tableName: string): Promise<T[]> => {
    try {
      const { data, error } = await supabase
        .from(tableName)
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data as T[];
    } catch (error: any) {
      console.error(`Supabase Error [getCollection ${tableName}]:`, error);
      throw new Error(`Impossible de récupérer ${tableName}: ${error.message}`);
    }
  },

  /**
   * Récupère un document par son ID
   */
  getDocument: async <T = any>(tableName: string, id: string): Promise<T | null> => {
    try {
      const { data, error } = await supabase
        .from(tableName)
        .select('*')
        .eq('id', id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') return null; // Pas trouvé
        throw error;
      }
      return data as T;
    } catch (error: any) {
      console.error(`Supabase Error [getDocument ${tableName}/${id}]:`, error);
      throw new Error(`Document non trouvé: ${error.message}`);
    }
  },

  /**
   * Crée un nouveau document avec ID auto-généré (UUID)
   */
  addDocument: async <T = any>(tableName: string, data: Partial<T>): Promise<T> => {
    try {
      const { data: newDoc, error } = await supabase
        .from(tableName)
        .insert([data])
        .select()
        .single();

      if (error) throw error;
      console.log(`✅ Document créé dans [${tableName}]:`, newDoc.id);
      return newDoc as T;
    } catch (error: any) {
      console.error(`Supabase Error [addDocument ${tableName}]:`, error);
      throw new Error(`Création échouée: ${error.message}`);
    }
  },

  /**
   * Crée/Écrase un document avec un ID spécifique (pour users avec UID Firebase)
   */
  setDocument: async <T = any>(
    tableName: string,
    id: string,
    data: Partial<T>
  ): Promise<void> => {
    try {
      const { error } = await supabase
        .from(tableName)
        .upsert({ ...data, id }, { onConflict: 'id' });

      if (error) throw error;
      console.log(`✅ Document upsert dans [${tableName}]:`, id);
    } catch (error: any) {
      console.error(`Supabase Error [setDocument ${tableName}/${id}]:`, error);
      throw new Error(`Upsert échoué: ${error.message}`);
    }
  },

  /**
   * Met à jour un document existant
   */
  updateDocument: async <T = any>(
    tableName: string,
    id: string,
    updates: Partial<T>
  ): Promise<T> => {
    try {
      const { data, error } = await supabase
        .from(tableName)
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      console.log(`✅ Document mis à jour [${tableName}/${id}]`);
      return data as T;
    } catch (error: any) {
      console.error(`Supabase Error [updateDocument ${tableName}/${id}]:`, error);
      throw new Error(`Mise à jour échouée: ${error.message}`);
    }
  },

  /**
   * Supprime un document
   */
  deleteDocument: async (tableName: string, id: string): Promise<boolean> => {
    try {
      const { error } = await supabase.from(tableName).delete().eq('id', id);

      if (error) throw error;
      console.log(`🗑️ Document supprimé [${tableName}/${id}]`);
      return true;
    } catch (error: any) {
      console.error(`Supabase Error [deleteDocument ${tableName}/${id}]:`, error);
      throw new Error(`Suppression échouée: ${error.message}`);
    }
  },

  /**
   * Requête avec filtres avancés
   */
  queryCollection: async <T = any>(
    tableName: string,
    filters: { column: string; operator: string; value: any }[] = [],
    orderBy?: string,
    orderDirection: 'asc' | 'desc' = 'desc',
    limitCount?: number
  ): Promise<T[]> => {
    try {
      let query = supabase.from(tableName).select('*');

      // Appliquer les filtres
      filters.forEach(({ column, operator, value }) => {
        switch (operator) {
          case '==':
            query = query.eq(column, value);
            break;
          case '!=':
            query = query.neq(column, value);
            break;
          case '>':
            query = query.gt(column, value);
            break;
          case '>=':
            query = query.gte(column, value);
            break;
          case '<':
            query = query.lt(column, value);
            break;
          case '<=':
            query = query.lte(column, value);
            break;
          case 'in':
            query = query.in(column, value);
            break;
          case 'contains':
            query = query.contains(column, value);
            break;
          default:
            console.warn(`Opérateur non supporté: ${operator}`);
        }
      });

      // Tri
      if (orderBy) {
        query = query.order(orderBy, { ascending: orderDirection === 'asc' });
      }

      // Limite
      if (limitCount) {
        query = query.limit(limitCount);
      }

      const { data, error } = await query;
      if (error) throw error;

      return data as T[];
    } catch (error: any) {
      console.error(`Supabase Error [queryCollection ${tableName}]:`, error);
      throw new Error(`Requête échouée: ${error.message}`);
    }
  },

  /**
   * Compte le nombre de documents
   */
  countDocuments: async (
    tableName: string,
    filters: { column: string; operator: string; value: any }[] = []
  ): Promise<number> => {
    try {
      let query = supabase.from(tableName).select('*', { count: 'exact', head: true });

      filters.forEach(({ column, operator, value }) => {
        if (operator === '==') query = query.eq(column, value);
      });

      const { count, error } = await query;
      if (error) throw error;

      return count || 0;
    } catch (error: any) {
      console.error(`Supabase Error [countDocuments ${tableName}]:`, error);
      return 0;
    }
  },

  /**
   * Vérifie si un document existe
   */
  documentExists: async (tableName: string, id: string): Promise<boolean> => {
    try {
      const { data, error } = await supabase
        .from(tableName)
        .select('id')
        .eq('id', id)
        .single();

      return !error && !!data;
    } catch {
      return false;
    }
  },
};