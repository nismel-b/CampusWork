import ProjectCard from "../components/projectcard";
import { useOutletContext } from "react-router-dom";

export default function Projects() {
  const { projects, loading } = useOutletContext();

  if (loading) return <p>Chargement...</p>;
  if (projects.length === 0) return <p>Aucun projet trouvé</p>;

  return (
    <div className="grid grid-cols-3 gap-8">
      {projects.map(project => (
        <ProjectCard key={project.id} project={project} />
      ))}
    </div>
  );
}
