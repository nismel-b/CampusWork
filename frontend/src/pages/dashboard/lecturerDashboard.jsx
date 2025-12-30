import { useEffect, useState } from "react";
import { lecturerService } from "../../services/lecturerService";

export default function LecturerDashboard() {
  const [projects, setProjects] = useState([]);

  useEffect(() => {
    lecturerService.getSupervisedProjects().then(res => {
      setProjects(res.data);
    });
  }, []);

  return (
    <div>
      <h2>Encadrant</h2>
      <ul>
        {projects.map(p => (
          <li key={p.id}>
            {p.title}
            <button onClick={() => lecturerService.validateProject(p.id)}>
              Valider
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
