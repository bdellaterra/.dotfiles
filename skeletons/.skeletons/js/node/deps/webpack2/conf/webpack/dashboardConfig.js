import { resolve } from 'path'

import DashboardPlugin from 'webpack-dashboard/plugin'

export default {
    plugins: [
        new DashboardPlugin(),
    ]
}

