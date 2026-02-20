export default function Show({ project }) {
  return (
    <div>
      <h1>{project.name}</h1>
      <p>{project.description}</p>
      <p>Status: {project.status}</p>
      <p>Progress: {project.progress}%</p>
    </div>
  );
}
