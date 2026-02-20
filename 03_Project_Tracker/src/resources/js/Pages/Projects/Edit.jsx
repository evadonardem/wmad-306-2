import { useForm } from "@inertiajs/react";

export default function Edit({ project }) {
  const { data, setData, put } = useForm(project);

  const submit = () =>
    put(`/projects/${project.id}`);

  return (
    <div>
      <h1>Edit</h1>

      <input
        value={data.name}
        onChange={e => setData("name", e.target.value)}
      />

      <button onClick={submit}>Update</button>
    </div>
  );
}
