import { useActions, useValues } from 'kea'
import { frameLogic } from '../../frameLogic'
import { templatesLogic } from './templatesLogic'
import { Button } from '../../../../components/Button'
import { Form } from 'kea-forms'
import { Modal } from '../../../../components/Modal'
import { Field } from '../../../../components/Field'
import { TextInput } from '../../../../components/TextInput'
import { TextArea } from '../../../../components/TextArea'
import { Image } from '../Image/Image'
import { Box } from '../../../../components/Box'
import { H6 } from '../../../../components/H6'
import { Tag } from '../../../../components/Tag'
import { CheckIcon, NoSymbolIcon } from '@heroicons/react/24/solid'
import clsx from 'clsx'
import { Spinner } from '../../../../components/Spinner'
import React from 'react'

export function EditTemplateModal() {
  const { frameId, frameForm } = useValues(frameLogic)
  const { isTemplateFormSubmitting, showingModal, modalTarget, templateForm } = useValues(templatesLogic({ frameId }))
  const { hideModal, submitTemplateForm } = useActions(templatesLogic({ frameId }))
  const newTemplate = !templateForm.id
  return (
    <>
      {showingModal ? (
        <Form logic={templatesLogic} props={{ frameId }} formKey="templateForm">
          <Modal
            title={
              newTemplate
                ? modalTarget === 'localTemplate'
                  ? 'Save as template'
                  : 'Download as .zip'
                : 'Edit template'
            }
            onClose={hideModal}
            open={showingModal}
            footer={
              <div className="flex items-top justify-end gap-2 p-6 border-t border-solid border-blueGray-200 rounded-b">
                <Button color="none" onClick={hideModal}>
                  Close
                </Button>
                <Button color="primary" onClick={submitTemplateForm} className="flex gap-2 items-center">
                  {isTemplateFormSubmitting ? <Spinner color="white" /> : null}
                  <div>
                    {newTemplate
                      ? modalTarget === 'localTemplate'
                        ? 'Save as template'
                        : 'Download .zip'
                      : 'Save changes'}
                  </div>
                </Button>
              </div>
            }
          >
            <div className="relative p-6 flex-auto space-y-4">
              <Field name="name" label="Template name">
                <TextInput placeholder="Template name" required />
              </Field>
              <Field name="description" label="Description">
                <TextArea placeholder="Pretty pictures..." rows={4} required />
              </Field>
              {newTemplate ? (
                <>
                  <Field
                    name="exportScenes"
                    label={`Scenes included in template (${templateForm.exportScenes?.length ?? 0} selected)`}
                  >
                    {({ value, onChange }) => (
                      <>
                        {(frameForm.scenes || []).map((scene, index) => {
                          const included = (value || []).includes(scene.id)
                          return (
                            <Box
                              key={scene.id}
                              className={clsx(
                                'p-2 flex flex-row gap-2 cursor-pointer items-center',
                                included ? '!bg-[#4a4b8c] !hover:bg-[#484984]' : 'bg-gray-900'
                              )}
                              onClick={(e) => {
                                e.preventDefault()
                                onChange(
                                  included
                                    ? (value || []).filter((v: string) => v !== scene.id)
                                    : [...(value || []), scene.id]
                                )
                              }}
                            >
                              {included ? <CheckIcon className="w-5 h-5" /> : <NoSymbolIcon className="w-5 h-5" />}
                              <div className="flex items-start justify-between gap-1">
                                <div>
                                  <H6>
                                    {scene.name || scene.id}
                                    {scene.default ? (
                                      <Tag className="ml-2" color="gray">
                                        default
                                      </Tag>
                                    ) : null}
                                  </H6>
                                  <div className="text-xs text-gray-400">id: {scene.id}</div>
                                </div>
                              </div>
                            </Box>
                          )
                        })}
                      </>
                    )}
                  </Field>
                  <Field name="image" label="Image">
                    <Image />
                  </Field>
                </>
              ) : null}
            </div>
          </Modal>
        </Form>
      ) : null}
    </>
  )
}
