import { Link } from "@inertiajs/react";

export default function Index({ projects }) {
  return (
    <div>
      <h1>Projects</h1>

      <Link href="/projects/create">Create Project</Link>

      {projects.data.map(p => (
        <div key={p.id}>
          <Link href={`/projects/${p.id}`}>
            {p.name}
          </Link>
        </div>
      ))}
    </div>
  );
}
