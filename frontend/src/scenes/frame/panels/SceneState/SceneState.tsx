import { useActions, useValues } from 'kea'
import { frameLogic } from '../../frameLogic'
import { sceneStateLogic } from './sceneStateLogic'
import { Form, Group } from 'kea-forms'
import { Field } from '../../../../components/Field'
import { TextInput } from '../../../../components/TextInput'
import { Select } from '../../../../components/Select'
import { configFieldTypes } from '../../../../types'
import { Button } from '../../../../components/Button'
import { Tooltip } from '../../../../components/Tooltip'
import { fieldTypeToGetter } from '../../../../utils/fieldTypes'
import { ClipboardDocumentIcon } from '@heroicons/react/24/outline'
import React from 'react'
import copy from 'copy-to-clipboard'

const PERSIST_OPTIONS = [
  { label: 'memory (reset on boot)', value: 'memory' },
  { label: 'disk (or sd card)', value: 'disk' },
]

const ACCESS_OPTIONS = [
  { label: 'private (use in the scene)', value: 'private' },
  { label: 'public (controllable externally)', value: 'public' },
]

export function SceneState(): JSX.Element {
  const sceneId = 'default'
  const { frameId } = useValues(frameLogic)
  const { sceneForm, editingFields } = useValues(sceneStateLogic({ frameId, sceneId }))
  const { setSceneFormValue, editField, closeField } = useActions(sceneStateLogic({ frameId, sceneId }))

  if (!sceneForm) {
    return <></>
  }

  return (
    <Form logic={sceneStateLogic} props={{ frameId, sceneId }} formKey="sceneForm" className="space-y-4">
      <Group name={[]}>
        <div className="bg-gray-900 p-2 space-y-4">
          <Field name="id" label="Scene ID">
            <TextInput disabled />
          </Field>
        </div>
        <div className="flex justify-between w-full items-center gap-2">
          <div className="flex items-center gap-2">
            <code className="font-bold">state</code>
            <Tooltip
              title={
                <>
                  The fields you set here will be available through{' '}
                  <code className="text-xs">{'state{"fieldName"}.getStr'}</code> in any app in this scene. The state is
                  just Nim's <code className="text-xs">JsonNode</code>, so access it accordingly. This means use{' '}
                  <code className="text-xs">{'state{"field"}.getStr'}</code> to access values, and{' '}
                  <pre className="text-xs">{'state{"field"} = %*("str")'}</pre> to store scalar values.
                </>
              }
            />
          </div>
          <Button
            onClick={() => {
              const newFields = [...(sceneForm.fields ?? []), { name: '', label: '', type: 'string' }]
              setSceneFormValue('fields', newFields)
              editField(newFields.length - 1)
            }}
            size="small"
          >
            Add field
          </Button>
        </div>
        {sceneForm.fields?.map((field, index) =>
          editingFields[index] ? (
            <Group name={['fields', index]}>
              <div className="bg-gray-900 p-2 space-y-4">
                <div className="flex justify-between items-center w-full gap-2">
                  <Button
                    onClick={() => {
                      setSceneFormValue(
                        'fields',
                        (sceneForm.fields ?? []).map((f, i) => (i === index ? undefined : f)).filter(Boolean)
                      )
                    }}
                    size="small"
                    color="red"
                  >
                    Remove field
                  </Button>
                  <Button onClick={() => closeField(index)} size="small">
                    Close
                  </Button>
                </div>
                <Field name="name" label="Name (keyword in code)">
                  <TextInput />
                </Field>
                <Field name="type" label="Type of field">
                  <Select options={configFieldTypes.filter((f) => f !== 'node').map((k) => ({ label: k, value: k }))} />
                </Field>
                <Field name="value" label="Initial value">
                  <TextInput />
                </Field>
                <Field name="label" label="Label (for user entry)">
                  <TextInput />
                </Field>
                <Field name="placeholder" label="Placeholder">
                  <TextInput />
                </Field>
                <Field
                  name="persist"
                  label="Perist"
                  tooltip={<>Persisting to disk reduces the lifetime of your SD card</>}
                >
                  <Select options={PERSIST_OPTIONS} />
                </Field>
                <Field
                  name="access"
                  label="Access"
                  tooltip={
                    <>
                      Whether this field is just usable within the scene (private), or if it can also be controlled
                      externally, for example from the frame's settings page.
                    </>
                  }
                >
                  <Select options={ACCESS_OPTIONS} />
                </Field>
              </div>
            </Group>
          ) : (
            <div className="bg-gray-900 p-2 space-y-4">
              <div className="flex justify-between items-center w-full gap-2">
                <div>{field.label || field.name}</div>
                <Button onClick={() => editField(index)} size="small">
                  Edit field
                </Button>
              </div>
              <div className="flex items-center gap-2">
                <code className="text-sm text-gray-400 break-words">{`state{"${field.name}"}${
                  fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr'
                }`}</code>
                <ClipboardDocumentIcon
                  className="w-4 h-4 min-w-4 min-h-4 cursor-pointer inline-block"
                  onClick={() =>
                    copy(`state{"${field.name}"}${fieldTypeToGetter[String(field.type ?? 'string')] ?? '.getStr'}`)
                  }
                />
              </div>
            </div>
          )
        )}
      </Group>
    </Form>
  )
}
