import Inferno from 'inferno'
import { Link } from 'inferno-router'

export const Nav = () => (
  <nav>
    <Link to="/">Home</Link>
    <Link to="/about">About</Link>
    <Link to="/nowhere">Nowhere</Link>
  </nav>
)

export default Nav
