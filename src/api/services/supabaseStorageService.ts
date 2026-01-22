// src/api/services/supabaseStorageService.ts
import { supabase, STORAGE_BUCKETS } from '../config/supabase';

/**
 * SERVICE SUPABASE STORAGE
 * Remplace Cloudinary pour le stockage des fichiers
 */

type BucketName = keyof typeof STORAGE_BUCKETS;

export const supabaseStorageService = {
  /**
   * Upload un fichier vers Supabase Storage
   * @param file - Fichier à uploader
   * @param bucketKey - Clé du bucket (AVATARS, COVERS, etc.)
   * @param folder - Sous-dossier optionnel
   * @returns URL publique du fichier
   */
  upload: async (
    file: File,
    bucketKey: BucketName,
    folder: string = ''
  ): Promise<string> => {
    try {
      const bucket = STORAGE_BUCKETS[bucketKey];
      
      // Générer un nom unique
      const timestamp = Date.now();
      const sanitizedName = file.name.replace(/[^a-zA-Z0-9.-]/g, '_');
      const fileName = `${folder ? folder + '/' : ''}${timestamp}_${sanitizedName}`;

      console.log(`📤 Upload vers [${bucket}/${fileName}]...`);

      // Upload vers Supabase
      const { data, error } = await supabase.storage
        .from(bucket)
        .upload(fileName, file, {
          cacheControl: '3600',
          upsert: false, // Erreur si le fichier existe déjà
        });

      if (error) throw error;

      // Récupérer l'URL publique
      const { data: publicUrlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(data.path);

      console.log(`✅ Fichier uploadé: ${publicUrlData.publicUrl}`);
      return publicUrlData.publicUrl;
    } catch (error: any) {
      console.error(`❌ Erreur upload [${bucketKey}]:`, error);
      throw new Error(`Upload échoué: ${error.message}`);
    }
  },

  /**
   * Supprime un fichier de Supabase Storage
   */
  delete: async (fileUrl: string, bucketKey: BucketName): Promise<boolean> => {
    try {
      const bucket = STORAGE_BUCKETS[bucketKey];
      
      // Extraire le chemin du fichier depuis l'URL
      const url = new URL(fileUrl);
      const pathSegments = url.pathname.split('/');
      const filePath = pathSegments.slice(pathSegments.indexOf(bucket) + 1).join('/');

      const { error } = await supabase.storage.from(bucket).remove([filePath]);

      if (error) throw error;

      console.log(`🗑️ Fichier supprimé: ${filePath}`);
      return true;
    } catch (error: any) {
      console.error(`❌ Erreur suppression [${bucketKey}]:`, error);
      return false;
    }
  },

  /**
   * Upload d'avatar
   */
  uploadAvatar: async (file: File): Promise<string> => {
    return supabaseStorageService.upload(file, 'AVATARS');
  },

  /**
   * Upload de couverture de projet
   */
  uploadCover: async (file: File): Promise<string> => {
    //return supabaseStorageService.upload(file, 'COVERS','projects');
     return supabaseStorageService.upload(file, 'COVERS');
  },

  /**
   * Upload de vidéo de projet
   */
  uploadVideo: async (file: File): Promise<string> => {
    // Vérifier la taille (limite 100MB pour exemple)
    const maxSize = 100 * 1024 * 1024; // 100MB
    if (file.size > maxSize) {
      throw new Error('La vidéo dépasse 100MB. Utilisez un lien YouTube/Vimeo.');
    }

    //return supabaseStorageService.upload(file, 'VIDEOS', 'demos');
    return supabaseStorageService.upload(file, 'VIDEOS');
  },

  /**
   * Upload de fichier annexe (PDF, DOCX, etc.)
   */
  uploadFile: async (file: File): Promise<{
    url: string;
    name: string;
    size: number;
    type: string;
  }> => {
    //const url = await supabaseStorageService.upload(file, 'FILES', 'documents');
    const url = await supabaseStorageService.upload(file, 'FILES');
    
    return {
      url,
      name: file.name,
      size: file.size,
      type: file.type,
    };
  },

  /**
   * Liste tous les fichiers d'un bucket
   */
  listFiles: async (bucketKey: BucketName, folder: string = ''): Promise<any[]> => {
    try {
      const bucket = STORAGE_BUCKETS[bucketKey];
      const { data, error } = await supabase.storage.from(bucket).list(folder);

      if (error) throw error;
      return data || [];
    } catch (error: any) {
      console.error(`❌ Erreur listage [${bucketKey}]:`, error);
      return [];
    }
  },

  /**
   * Récupère une URL signée temporaire (pour fichiers privés)
   */
  getSignedUrl: async (
    fileUrl: string,
    bucketKey: BucketName,
    expiresIn: number = 3600
  ): Promise<string> => {
    try {
      const bucket = STORAGE_BUCKETS[bucketKey];
      const url = new URL(fileUrl);
      const pathSegments = url.pathname.split('/');
      const filePath = pathSegments.slice(pathSegments.indexOf(bucket) + 1).join('/');

      const { data, error } = await supabase.storage
        .from(bucket)
        .createSignedUrl(filePath, expiresIn);

      if (error) throw error;
      return data.signedUrl;
    } catch (error: any) {
      console.error(`❌ Erreur URL signée:`, error);
      throw new Error(`Impossible de générer l'URL: ${error.message}`);
    }
  },
};