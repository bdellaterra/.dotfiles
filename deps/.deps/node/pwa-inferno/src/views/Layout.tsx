import Inferno from 'inferno'
import Nav from './Nav';

export const Layout = ({ children }) => (
  <div>
    <header>
      <Nav />
    </header>
    <main>
      {children}
    </main>
  </div>
)

export default Layout
