import { createFileRoute, useNavigate } from "@tanstack/react-router"
import { useMutation } from "@tanstack/react-query"
import { useForm } from "@tanstack/react-form"

export const Route = createFileRoute("/signup")({
  component: SignupComponent,
})

const signupApi = async (data: any) => {
  const res = await fetch("/api/signup", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: data.email, password: data.password }),
  })
  if (!res.ok) {
    const errorData = await res.json()
    throw new Error(errorData.message || "Signup failed")
  }
  return res.json()
}

function SignupComponent() {
  const navigate = useNavigate()

  const signupMutation = useMutation({
    mutationFn: signupApi,
    onSuccess: (data) => {
      localStorage.setItem("token", data.token)
      localStorage.setItem("user", JSON.stringify(data.user))
      navigate({ to: "/profile" })
    },
  })

  const form = useForm({
    defaultValues: {
      email: "",
      password: "",
      confirmPassword: "",
    },
    onSubmit: async ({ value }) => {
      if (value.password !== value.confirmPassword) {
        alert("Passwords do not match!")
        return
      }
      signupMutation.mutate(value)
    },
  })

  return (
    <div style={{ maxWidth: "400px", margin: "auto" }}>
      <h2>Signup</h2>
      <form
        onSubmit={(e) => {
          e.preventDefault()
          e.stopPropagation()
          form.handleSubmit()
        }}
        style={{ display: "flex", flexDirection: "column", gap: "1rem" }}
      >
        <form.Field
          name="email"
          children={(field) => (
            <input
              name={field.name}
              value={field.state.value}
              onBlur={field.handleBlur}
              onChange={(e) => field.handleChange(e.target.value)}
              type="email"
              placeholder="Email"
              required
            />
          )}
        />
        <form.Field
          name="password"
          children={(field) => (
            <input
              name={field.name}
              value={field.state.value}
              onBlur={field.handleBlur}
              onChange={(e) => field.handleChange(e.target.value)}
              type="password"
              placeholder="Password"
              required
            />
          )}
        />
        <form.Field
          name="confirmPassword"
          children={(field) => (
            <input
              name={field.name}
              value={field.state.value}
              onBlur={field.handleBlur}
              onChange={(e) => field.handleChange(e.target.value)}
              type="password"
              placeholder="Confirm Password"
              required
            />
          )}
        />
        {signupMutation.isError && (
          <p style={{ color: "red", fontSize: "0.875rem" }}>
            {signupMutation.error.message}
          </p>
        )}
        <button type="submit" disabled={signupMutation.isPending}>
          {signupMutation.isPending ? "Signing up..." : "Signup"}
        </button>
      </form>
    </div>
  )
}
