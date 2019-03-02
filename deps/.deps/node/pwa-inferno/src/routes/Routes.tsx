import Inferno from 'inferno'
import { Route, Switch } from 'inferno-router'
import Home from './Home'
import About from './About'
import NotFound from './NotFound'

export const Routes = () => (
  <Switch>
    <Route path="/" exact component={Home}/>
    <Route path="/about" component={About}/>
    <Route component={NotFound} />
  </Switch>
)

export default Routes
