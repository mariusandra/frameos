import { afterMount, connect, kea, key, listeners, path, props } from 'kea'

import type { sceneSourceLogicType } from './sceneSourceLogicType'
import { loaders } from 'kea-loaders'
import { frameLogic } from '../../frameLogic'
export interface SceneSourceLogicProps {
  frameId: number
}

export const sceneSourceLogic = kea<sceneSourceLogicType>([
  path(['src', 'scenes', 'frame', 'panels', 'SceneSource', 'sceneSourceLogic']),
  props({} as SceneSourceLogicProps),
  key((props) => props.frameId),
  connect(() => ({ actions: [frameLogic, ['submitFrameFormSuccess']] })),
  loaders(({ props }) => ({
    sceneSource: [
      '' as string,
      {
        loadSceneSource: async () => {
          const response = await fetch(`/api/frames/${props.frameId}/scene_source/default`)
          const result = await response.json()
          return result.source
        },
      },
    ],
  })),
  afterMount(({ actions }) => {
    actions.loadSceneSource()
  }),
  listeners(({ actions }) => ({
    submitFrameFormSuccess: () => {
      actions.loadSceneSource()
    },
  })),
])
