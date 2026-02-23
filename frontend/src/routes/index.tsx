import { createFileRoute } from "@tanstack/react-router"

export const Route = createFileRoute("/")({
  component: IndexComponent,
})

function IndexComponent() {
  return (
    <div>
      <h2>AWS Demo Home</h2>
      <p>Welcome to the demo application! Please Login or Signup to see your profile.</p>
    </div>
  )
}
