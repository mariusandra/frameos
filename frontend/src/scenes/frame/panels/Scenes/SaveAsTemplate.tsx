import { useActions, useValues } from 'kea'
import { frameLogic } from '../../frameLogic'
import { Button } from '../../../../components/Button'
import { templatesLogic } from './templatesLogic'
import { FolderArrowDownIcon } from '@heroicons/react/24/outline'

interface TemplatesProps extends React.HTMLAttributes<HTMLDivElement> {
  className?: string
}

export function SaveAsTemplate(props: TemplatesProps) {
  const { frameId, frameForm } = useValues(frameLogic)
  const { saveAsLocalTemplate } = useActions(templatesLogic({ frameId }))

  return (
    <div {...props}>
      <Button
        size="small"
        color="secondary"
        className="flex gap-1 items-center"
        onClick={() => saveAsLocalTemplate({ name: frameForm.name })}
      >
        <FolderArrowDownIcon className="w-4 h-4" />
        Save as a local template
      </Button>
    </div>
  )
}
