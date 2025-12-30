import { useEffect, useState } from "react";
import { adminService } from "../../services/adminService";

export default function AdminDashboard() {
  const [users, setUsers] = useState([]);

  useEffect(() => {
    adminService.getAllUsers().then(res => {
      setUsers(res.data);
    });
  }, []);

  return (
    <div>
      <h2>Admin</h2>
      <ul>
        {users.map(u => (
          <li key={u.id}>
            {u.email}
            <button onClick={() => adminService.deleteUser(u.id)}>
              Supprimer
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
