import { actions, afterMount, connect, kea, key, listeners, path, props, reducers, selectors } from 'kea'
import { framesModel } from '../../models/framesModel'
import type { frameLogicType } from './frameLogicType'
import { subscriptions } from 'kea-subscriptions'
import { FrameScene, FrameType, TemplateType } from '../../types'
import { forms } from 'kea-forms'
import equal from 'fast-deep-equal'
import { v4 as uuidv4 } from 'uuid'

export interface FrameLogicProps {
  frameId: number
}
const FRAME_KEYS: (keyof FrameType)[] = [
  'name',
  'frame_host',
  'frame_port',
  'frame_access_key',
  'frame_access',
  'ssh_user',
  'ssh_pass',
  'ssh_port',
  'server_host',
  'server_port',
  'server_api_key',
  'width',
  'height',
  'color',
  'device',
  'interval',
  'metrics_interval',
  'scaling_mode',
  'rotate',
  'background_color',
  'scenes',
  'debug',
]

export function sanitizeScene(scene: Partial<FrameScene>): FrameScene {
  return {
    ...scene,
    id: scene.id ?? uuidv4(),
    name: scene.name || 'Untitled scene',
    nodes: scene.nodes ?? [],
    edges: scene.edges ?? [],
    fields: scene.fields ?? [],
    settings: scene.settings ?? {},
  }
}

export const frameLogic = kea<frameLogicType>([
  path(['src', 'scenes', 'frame', 'frameLogic']),
  props({} as FrameLogicProps),
  key((props) => props.frameId),
  connect({ values: [framesModel, ['frames']] }),
  actions({
    updateScene: (sceneId: string, scene: Partial<FrameScene>) => ({ sceneId, scene }),
    updateNodeData: (sceneId: string, nodeId: string, nodeData: Record<string, any>) => ({ sceneId, nodeId, nodeData }),
    saveFrame: true,
    renderFrame: true,
    restartFrame: true,
    stopFrame: true,
    deployFrame: true,
    applyTemplate: (template: TemplateType) => ({ template }),
  }),
  forms(({ actions, values }) => ({
    frameForm: {
      options: {
        showErrorsOnTouch: true,
      },
      defaults: {} as FrameType,
      errors: (state: Partial<FrameType>) => ({
        scenes: (state.scenes ?? []).map((scene: Record<string, any>) => ({
          fields: (scene.fields ?? []).map((field: Record<string, any>) => ({
            name: field.name ? '' : 'Name is required',
            label: field.label ? '' : 'Label is required',
            type: field.type ? '' : 'Type is required',
          })),
        })),
      }),
      submit: async (frame, breakpoint) => {
        const json: Record<string, any> = {}
        for (const key of FRAME_KEYS) {
          json[key] = frame[key as keyof typeof frame]
        }
        if (values.nextAction) {
          json['next_action'] = values.nextAction
        }
        const response = await fetch(`/api/frames/${values.frameId}`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(json),
        })
        if (!response.ok) {
          throw new Error('Failed to update frame')
        }
      },
    },
  })),
  reducers({
    nextAction: [
      null as 'render' | 'restart' | 'stop' | 'deploy' | null,
      {
        saveFrame: () => null,
        renderFrame: () => 'render',
        restartFrame: () => 'restart',
        stopFrame: () => 'stop',
        deployFrame: () => 'deploy',
      },
    ],
  }),
  selectors(() => ({
    frameId: [() => [(_, props) => props.frameId], (frameId) => frameId],
    frame: [(s) => [s.frames, s.frameId], (frames, frameId) => frames[frameId] || null],
    frameChanged: [
      (s) => [s.frame, s.frameForm],
      (frame, frameForm) =>
        FRAME_KEYS.some((key) => !equal(frame?.[key as keyof FrameType], frameForm?.[key as keyof FrameType])),
    ],
    defaultScene: [
      (s) => [s.frame, s.frameForm],
      (frame, frameForm) => {
        const allScenes = frameForm?.scenes ?? frame?.scenes ?? []
        return (allScenes.find((scene) => scene.id === 'default' || scene.default) || allScenes[0])?.id ?? null
      },
    ],
  })),
  subscriptions(({ actions }) => ({
    frame: (frame, oldFrame) => {
      if (frame && !oldFrame) {
        actions.resetFrameForm(frame)
      }
    },
  })),
  listeners(({ actions, values, props }) => ({
    renderFrame: () => framesModel.actions.renderFrame(props.frameId),
    saveFrame: () => actions.submitFrameForm(),
    deployFrame: () => actions.submitFrameForm(),
    restartFrame: () => actions.submitFrameForm(),
    stopFrame: () => actions.submitFrameForm(),
    updateScene: ({ sceneId, scene }) => {
      const { frame } = values
      const hasScene = frame.scenes?.some(({ id }) => id === sceneId)
      actions.setFrameFormValues({
        scenes: hasScene
          ? frame.scenes?.map((s) => (s.id === sceneId ? sanitizeScene({ ...s, ...scene }) : s))
          : [...(frame.scenes ?? []), sanitizeScene({ ...scene, id: sceneId })],
      })
    },
    updateNodeData: ({ sceneId, nodeId, nodeData }) => {
      const { frame, frameForm } = values
      const scenes = frameForm.scenes ?? frame.scenes
      const scene = scenes?.find(({ id }) => id === sceneId)
      const currentNode = scene?.nodes?.find(({ id }) => id === nodeId)
      if (currentNode) {
        actions.setFrameFormValues({
          scenes: scenes?.map((s) =>
            s.id === sceneId
              ? {
                  ...s,
                  nodes: s.nodes?.map((n) =>
                    n.id === nodeId ? { ...n, data: { ...(n.data ?? {}), ...nodeData } } : n
                  ),
                }
              : s
          ),
        })
      } else {
        console.error(`Node ${nodeId} not found in scene ${sceneId}`)
      }
    },
    applyTemplate: ({ template }) => {
      actions.setFrameFormValues({
        ...('scenes' in template ? { scenes: template.scenes } : {}),
        ...('interval' in (template.config ?? {}) ? { interval: template.config?.interval } : {}),
        ...('scaling_mode' in (template.config ?? {}) ? { scaling_mode: template.config?.scaling_mode } : {}),
        ...('rotate' in (template.config ?? {}) ? { rotate: template.config?.rotate } : {}),
        ...('background_color' in (template.config ?? {})
          ? { background_color: template.config?.background_color }
          : {}),
      })
    },
  })),
  afterMount(({ actions, values }) => {
    const defaultScene = values.frame?.scenes?.find((scene) => scene.id === 'default' && !scene.default)
    if (defaultScene) {
      const { name, id, default: _def, ...rest } = defaultScene
      actions.updateScene('default', { name: 'Default Scene', id: uuidv4(), default: true, ...rest })
    }
  }),
])
