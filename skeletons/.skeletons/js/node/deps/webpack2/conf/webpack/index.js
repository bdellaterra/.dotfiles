import merge from 'webpack-merge'
import requireDir from 'require-dir'

const modules = requireDir()

export default merge(...Object.values(modules).map(o => o.default))
