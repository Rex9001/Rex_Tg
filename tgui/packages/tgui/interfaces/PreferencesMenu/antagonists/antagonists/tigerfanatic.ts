import { type Antagonist, Category } from '../base';

const Fanatic: Antagonist = {
  key: 'fanatic',
  name: 'Fanatic',
  description: [
    `
      Praise the shapeshifters! You have completed holy pilgrimage to
      space station 13, beckoned by the whispers of the changeling hive!
      Worship your idols, and perhaps you can become one with the changeling
      hive!
    `,

    `
      Worship the changelings, play the perfect evil minion!
      Coordinate with your idols by speaking in hive chat.
      Changeling abilities have additional effects on you.
      Receive their blessings.
    `,
  ],
  category: Category.Midround,
};

export default Fanatic;
