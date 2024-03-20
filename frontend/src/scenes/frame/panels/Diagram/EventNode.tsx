import { useValues } from 'kea'
import { NodeProps, Handle, Position } from 'reactflow'
import clsx from 'clsx'
import { diagramLogic } from './diagramLogic'
import copy from 'copy-to-clipboard'
import { FrameEvent } from '../../../../types'
import { fieldTypeToGetter } from '../../../../utils/fieldTypes'

import _events from '../../../../../schema/events.json'
import { ClipboardIcon } from '@heroicons/react/24/solid'

const events: FrameEvent[] = _events as any

export function EventNode(props: NodeProps): JSX.Element {
  const { data, id } = props
  const { selectedNodeId, scene } = useValues(diagramLogic)
  const { keyword } = data

  const isEventWithStateFields = keyword === 'init' || keyword === 'setSceneState' || keyword === 'render'

  const fields = isEventWithStateFields ? scene?.fields ?? [] : events?.find((e) => e.name == keyword)?.fields ?? []

  return (
    <div
      className={clsx(
        'shadow-lg border border-2',
        selectedNodeId === id
          ? 'bg-black bg-opacity-70 border-indigo-900 shadow-indigo-700/50'
          : 'bg-black bg-opacity-70 border-red-900 shadow-red-700/50 '
      )}
    >
      <div
        className={clsx(
          'flex gap-2 justify-between items-center frameos-node-title text-xl p-1',
          selectedNodeId === id ? 'bg-indigo-900' : 'bg-red-900'
        )}
      >
        <div>{keyword}</div>
        <Handle
          type="source"
          position={Position.Right}
          id="next"
          style={{
            position: 'relative',
            transform: 'none',
            width: 20,
            height: 20,
            right: 0,
            top: 0,
            background: 'rgba(200, 200, 200, 0.8)',
            borderBottomLeftRadius: 0,
            borderTopLeftRadius: 0,
          }}
        />
      </div>
      {fields.length > 0 ? (
        <div className="p-1">
          {fields.map((field: Record<string, any>) => (
            <div className="flex items-center justify-end space-x-1 w-full">
              <code className="text-xs mr-2 text-gray-400 flex-1">{field.type}</code>
              <div title={field.label}>{field.name}</div>
              <ClipboardIcon
                className="w-5 h-5 cursor-pointer"
                onClick={() =>
                  copy(
                    isEventWithStateFields
                      ? `state{"${field.name}"}${fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr()'}`
                      : `context.payload{"${field.name}"}${
                          fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr()'
                        }`
                  )
                }
              />
              <Handle
                type="source"
                position={Position.Right}
                id={
                  isEventWithStateFields
                    ? `code/state{"${field.name}"}${fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr()'}`
                    : `code/context.payload{"${field.name}"}${
                        fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr()'
                      }`
                }
                style={{ position: 'relative', transform: 'none', right: 0, top: 0, background: '#000000' }}
              />
            </div>
          ))}
        </div>
      ) : null}
    </div>
  )
}
