import ChartPage from '@/components/ChartPage.vue'
import ActionPage from '@/components/ActionPage.vue'
import ConfigPage from '@/components/ConfigPage.vue'
import {createMemoryHistory, createRouter} from "vue-router";


const routes = [
    {
        path: '/',
        name: 'Chart',
        component: ChartPage
    },
    {
        path: '/actions',
        name: 'Actions',
        component: ActionPage
    },
    {
        path: '/config',
        name: 'Configuration',
        component: ConfigPage
    }
]

const router = createRouter({
    history: createMemoryHistory(),
    routes,
})

export default router