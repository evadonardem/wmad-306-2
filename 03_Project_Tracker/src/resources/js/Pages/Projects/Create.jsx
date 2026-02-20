import { useForm } from "@inertiajs/react";

export default function Create() {
  const { data, setData, post } = useForm({
    name: "",
    description: "",
    status: "pending",
    due_date: "",
    progress: 0
  });

  const submit = () => post("/projects");

  return (
    <div>
      <h1>Create Project</h1>

      <input
        value={data.name}
        onChange={e => setData("name", e.target.value)}
        placeholder="Name"
      />

      <button onClick={submit}>Save</button>
    </div>
  );
}
