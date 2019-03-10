import Nav from "./Nav"

interface LayoutProps {
  children?: any;
}

export const Layout = ({ children }: LayoutProps) => (
  <div>
    <header>
      <Nav />
    </header>
    <main>{children}</main>
  </div>
)

export default Layout
