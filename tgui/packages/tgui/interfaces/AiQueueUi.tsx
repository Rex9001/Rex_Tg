import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Command = {
  name: string;
  processing: number;
  process_required: number;
};

type SpecCommand = {
  name: string;
  process_required: number;
};

type Data = {
  ram: number;
  processing_power: number;
  queue_length: number;
  is_paused: BooleanLike;
  is_processing: BooleanLike;
  commands: Command[];
  unlocked: SpecCommand[];
};

export const AiQueueUi = () => {
  const { data } = useBackend<Data>();
  const { commands, unlocked } = data;

  return (
    <Window title="AI Command Queue" width={420} height={480}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <QueueStatus />
          </Stack.Item>
          <Stack.Item grow>
            <QueueList commands={commands} />
          </Stack.Item>
          <Stack.Item grow>
            <QueueSpecList unlocked={unlocked} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const QueueStatus = () => {
  const { data, act } = useBackend<Data>();
  const { ram, processing_power, queue_length, is_paused, is_processing } =
    data;

  return (
    <Section title="Status">
      <LabeledList>
        <LabeledList.Item label="RAM">
          <ProgressBar
            value={queue_length}
            minValue={0}
            maxValue={Math.max(1, ram)}
            ranges={{
              good: [0, ram * 0.7],
              average: [ram * 0.7, ram * 0.9],
              bad: [ram * 0.9, ram],
            }}
          >
            {queue_length} / {ram}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Processing Power">
          {processing_power}
        </LabeledList.Item>
        <LabeledList.Item label="Queue State">
          {is_paused ? 'Paused' : 'Active'}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1}>
        <Button.Confirm
          width="100%"
          textAlign="center"
          fontSize="16px"
          icon={is_paused ? 'play' : 'pause'}
          color={is_paused ? 'green' : 'red'}
          confirmColor="blue"
          onClick={() => act('toggle_pause')}
        >
          {is_paused ? 'Resume Queue' : 'Pause Queue'}
        </Button.Confirm>
      </Box>
    </Section>
  );
};

/** Ordered list of commands currently in the queue, with per-command progress. */
const QueueList = (props: { commands: Command[] }) => {
  const { commands } = props;

  return (
    <Section title="Command Queue" fill scrollable>
      {commands.length === 0 ? (
        <Box color="label" italic>
          No commands queued.
        </Box>
      ) : (
        <Stack vertical>
          {commands.map((command, index) => (
            <Stack.Item key={index} className="candystripe">
              <CommandRow command={command} position={index + 1} />
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const CommandRow = (props: { command: Command; position: number }) => {
  const { command, position } = props;

  return (
    <Box p={0.5}>
      <Box bold>
        {position}. {command.name}
      </Box>
      <ProgressBar
        value={command.processing}
        minValue={0}
        maxValue={Math.max(1, command.process_required)}
      >
        {command.processing} process out of {command.process_required} required
      </ProgressBar>
    </Box>
  );
};

/** List of commands that have been unlocked but not yet queued/run. */
const QueueSpecList = (props: { unlocked: SpecCommand[] }) => {
  const { unlocked } = props;

  return (
    <Section title="Unlocked Commands" fill scrollable>
      {unlocked.length === 0 ? (
        <Box color="label" italic>
          No commands unlocked.
        </Box>
      ) : (
        <Stack vertical>
          {unlocked.map((specCommand, index) => (
            <Stack.Item key={index} className="candystripe">
              <SpecCommandRow specCommand={specCommand} position={index + 1} />
            </Stack.Item>
          ))}
        </Stack>
      )}
    </Section>
  );
};

const SpecCommandRow = (props: {
  specCommand: SpecCommand;
  position: number;
}) => {
  const { act } = useBackend<Data>();
  const { specCommand, position } = props;

  return (
    <Button
      fluid
      onClick={() => act('add_to_queue', { command: specCommand.name })}
    >
      <Box bold>
        {position}. {specCommand.name}
      </Box>
      <Box>Requires {specCommand.process_required} processing</Box>
    </Button>
  );
};
