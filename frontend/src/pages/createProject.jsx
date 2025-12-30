import { useState } from "react";
import { projectService } from "../services/projectService";

export default function CreateProject() {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [file, setFile] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);

    if (!file) {
      setError("Veuillez sélectionner un fichier");
      return;
    }

    const formData = new FormData();
    formData.append("title", title);
    formData.append("description", description);
    formData.append("file", file);

    try {
      setLoading(true);
      await projectService.create(formData);
      alert("Projet créé avec succès");
      setTitle("");
      setDescription("");
      setFile(null);
    } catch (err) {
      setError(
        err?.response?.data?.message ||
        "Erreur lors de la création du projet"
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: 500, margin: "auto" }}>
      <h2>Créer un projet</h2>

      {error && <p style={{ color: "red" }}>{error}</p>}

      <form onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Titre"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
        />

        <textarea
          placeholder="Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          required
        />

        <input
          type="file"
          onChange={(e) => setFile(e.target.files[0])}
          accept=".pdf,.doc,.docx,.zip"
        />

        <button type="submit" disabled={loading}>
          {loading ? "Envoi..." : "Créer"}
        </button>
      </form>
    </div>
  );
}
