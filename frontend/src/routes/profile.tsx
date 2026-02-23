import { createFileRoute, useNavigate } from "@tanstack/react-router"
import { useQuery } from "@tanstack/react-query"

export const Route = createFileRoute("/profile")({
  component: ProfileComponent,
})

const fetchProfile = async () => {
  const token = localStorage.getItem("token")
  if (!token) throw new Error("No token found")

  const res = await fetch("/api/profile", {
    headers: { Authorization: `Bearer ${token}` },
  })
  if (!res.ok) {
    if (res.status === 401 || res.status === 403) {
      localStorage.removeItem("token")
      localStorage.removeItem("user")
    }
    throw new Error("Failed to fetch profile")
  }
  return res.json()
}

function ProfileComponent() {
  const navigate = useNavigate()

  const { data, isLoading, isError } = useQuery({
    queryKey: ["profile"],
    queryFn: fetchProfile,
    retry: false,
  })

  const handleLogout = () => {
    localStorage.removeItem("token")
    localStorage.removeItem("user")
    navigate({ to: "/login" })
  }

  if (isLoading) return <p>Loading...</p>
  if (isError) {
    navigate({ to: "/login" })
    return null
  }

  return (
    <div style={{ maxWidth: "400px", margin: "auto" }}>
      <h2>Profile</h2>
      <div style={{ display: "flex", flexDirection: "column", gap: "1rem" }}>
        <p>Email: {data.user.email}</p>
        <button onClick={handleLogout}>Logout</button>
      </div>
    </div>
  )
}
