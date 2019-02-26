import { render } from "inferno";
import { initDevTools } from "inferno-devtools"
import App from './App'

initDevTools()

render(<App />, document.getElementById("app"));
