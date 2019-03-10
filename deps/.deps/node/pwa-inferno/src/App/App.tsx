import { BrowserRouter } from "inferno-router"
import Routes from "routes/Routes"
import Layout from "views/Layout"

const App = () => (
  <BrowserRouter>
    <Layout>
      <Routes />
    </Layout>
  </BrowserRouter>
)

export default App
