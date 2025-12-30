import { useEffect, useState } from "react";
import { studentService } from "../../services/studentService";

export default function StudentDashboard() {
  const [profile, setProfile] = useState(null);

  useEffect(() => {
    studentService.getProfile().then(res => {
      setProfile(res.data);
    });
  }, []);

  if (!profile) return <p>Chargement...</p>;

  return (
    <div>
      <h2>Étudiant</h2>
      <p>Nom : {profile.name}</p>
      <p>Email : {profile.email}</p>
    </div>
  );
}
