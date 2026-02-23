import { createRootRoute, Link, Outlet } from "@tanstack/react-router";

export const Route = createRootRoute({
  component: RootComponent,
});

function RootComponent() {
  return (
    <>
      <nav style={{ padding: "1rem", borderBottom: "1px solid #ccc", display: "flex", gap: "1rem" }}>
        <Link to="/" activeProps={{ style: { fontWeight: "bold" } }}>Home</Link>
        <Link to="/login" activeProps={{ style: { fontWeight: "bold" } }}>Login</Link>
        <Link to="/signup" activeProps={{ style: { fontWeight: "bold" } }}>Signup</Link>
        <Link to="/profile" activeProps={{ style: { fontWeight: "bold" } }}>Profile</Link>
      </nav>
      <main style={{ padding: "1rem" }}>
        <Outlet />
      </main>
    </>
  );
}
