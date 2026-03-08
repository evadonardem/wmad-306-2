import { Head } from '@inertiajs/react'
import { useState } from 'react'

export default function List() {
  const mails = [
    { id: 1, name: 'Alice Johnson', subject: 'Project Update', body: 'Final review tomorrow.' },
    { id: 2, name: 'Bob Smith', subject: 'Meeting Reminder', body: '3PM meeting today.' },
    { id: 3, name: 'Charlie Cruz', subject: 'Welcome!', body: 'Glad to have you here.' },
    { id: 4, name: 'Diana Reyes', subject: 'Invoice', body: 'Invoice attached.' },
    { id: 5, name: 'Ethan Walker', subject: 'Maintenance', body: 'Downtime at midnight.' },
  ]

  const [activeId, setActiveId] = useState(mails[0].id)
  const active = mails.find(m => m.id === activeId)

  return (
    <>
      <Head title="Inbox" />

      <div style={{ display: 'grid', gridTemplateColumns: '320px 1fr', height: 'calc(100vh - 64px)' }}>
        <aside style={{ borderRight: '1px solid #1e293b' }}>
          {mails.map(m => (
            <div
              key={m.id}
              onClick={() => setActiveId(m.id)}
              style={{
                padding: '1rem',
                cursor: 'pointer',
                background: m.id === activeId ? '#312e81' : 'transparent',
              }}
            >
              <strong>{m.name}</strong>
              <div style={{ opacity: 0.7 }}>{m.subject}</div>
            </div>
          ))}
        </aside>

        <main style={{ padding: '2rem' }}>
          <h2>{active.subject}</h2>
          <p style={{ opacity: 0.7 }}>From: {active.name}</p>
          <p>{active.body}</p>
        </main>
      </div>
    </>
  )
}
