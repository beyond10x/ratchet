import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {withProductSite} from '@beyond10x/docs-system/product-site';

// The documentation pages are the repository's own Markdown, read in place from the repository
// root: vision.md, docs/design.md and research/. Nothing is copied into website/. The table below
// gives each file its route, its title and the header the docs-system theme draws over it (lede,
// status, source link); the files themselves stay as they are on GitHub. The landing page is
// src/pages/index.tsx, which draws product.json with the docs-system product template.

const siteDir = path.dirname(fileURLToPath(import.meta.url));
const repositoryRoot = path.resolve(siteDir, '..');
const sourceBase = 'https://github.com/beyond10x/ratchet/blob/main/';

const releaseState =
  'Release 0.0.1 ships a ratchet binary that parses the 16 commands and prints its version; no command is built yet, so it checks nothing for a project.';

interface Page {
  slug: string;
  title: string;
  sidebar_label?: string;
  lede: string;
  status?: 'planned';
}

const pages: Record<string, Page> = {
  'vision.md': {
    slug: '/',
    title: 'Vision',
    lede: `Why Ratchet exists, the outcomes it aims for and what it does not do. ${releaseState}`,
    status: 'planned',
  },
  'docs/design.md': {
    slug: '/design',
    title: 'Design proposal',
    lede: `${releaseState} Field names, document shapes and CLI commands on this page are proposals, not settled.`,
    status: 'planned',
  },
  'docs/product-brainstorm.md': {
    slug: '/product-brainstorm',
    title: 'Product brainstorm',
    lede: `${releaseState} What Ratchet is beyond the specification: binary, local config, record store, views and integrations. Nothing on this page is decided.`,
    status: 'planned',
  },
  'docs/open-questions.md': {
    slug: '/open-questions',
    title: 'Open questions',
    lede: `${releaseState} Six product questions with lettered options and a recommended default each.`,
    status: 'planned',
  },
  'research/README.md': {
    slug: '/research',
    title: 'Research',
    lede: 'Evidence for the design, gathered before any implementation planning, and the confidentiality rules for survey answers.',
  },
  'research/survey-quality-tracking.md': {
    slug: '/research/survey',
    title: 'Survey 1: questions',
    lede: 'The questions of survey 1 and the template each answer follows.',
  },
  'research/synthesis.md': {
    slug: '/research/synthesis',
    title: 'Survey 1: synthesis',
    lede: 'The patterns across the answers to survey 1 and what they imply for the design.',
  },
  'research/candidate-presets.md': {
    slug: '/research/candidate-presets',
    title: 'Candidate presets',
    lede: `First presets the survey answers support. Design input: the catalog presets/ holds eight families (functional, latency and throughput, resources, start and readiness, operability, build, artifact, code), and no command resolves a binding yet. ${releaseState}`,
    status: 'planned',
  },
  'research/consumer-input-ux-ui.md': {
    slug: '/research/consumer-input-ux-ui',
    title: 'Consumer input: ux-ui',
    lede: 'Design input from the ux-ui repository, recorded as sent. It is not a decision.',
  },
};

function pageFor(file: string): Page | undefined {
  if (pages[file]) return pages[file];
  const answer = /^research\/responses\/([a-z0-9-]+)\.md$/.exec(file);
  if (!answer) return undefined;
  return {
    slug: `/research/responses/${answer[1]}`,
    title: `Survey 1 answer: ${answer[1]}`,
    sidebar_label: answer[1],
    lede: 'One answer to survey 1, as committed in the repository.',
  };
}

const config: Config = {
  title: 'ratchet',
  tagline: 'Specify software quality, then keep it from going backwards.',

  future: {v4: true},
  url: 'https://beyond10x.github.io',
  baseUrl: '/ratchet/',
  organizationName: 'beyond10x',
  projectName: 'ratchet',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,
  onBrokenLinks: 'throw',
  onBrokenAnchors: 'throw',

  markdown: {
    format: 'detect',
    hooks: {onBrokenMarkdownLinks: 'throw'},
    parseFrontMatter: async (params) => {
      const result = await params.defaultParseFrontMatter(params);
      const file = path.relative(repositoryRoot, params.filePath).split(path.sep).join('/');
      const page = pageFor(file);
      if (!page) return result;
      return {
        ...result,
        frontMatter: {
          ...result.frontMatter,
          ...page,
          source: file,
          source_url: sourceBase + file,
        },
      };
    },
  },
  i18n: {defaultLocale: 'en', locales: ['en']},

  presets: [
    [
      'classic',
      {
        docs: {
          path: '..',
          include: [
            'vision.md',
            'docs/design.md',
            'docs/product-brainstorm.md',
            'docs/open-questions.md',
            'research/*.md',
            'research/responses/*.md',
          ],
          sidebarPath: './sidebars.ts',
          routeBasePath: 'docs',
          editUrl: 'https://github.com/beyond10x/ratchet/tree/main/',
        },
        blog: false,
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'ratchet',
      items: [
        {to: '/docs/', label: 'Vision', position: 'left', activeBaseRegex: '^/ratchet/docs/?$'},
        {to: '/docs/design', label: 'Design', position: 'left'},
        {to: '/docs/research', label: 'Research', position: 'left', activeBaseRegex: '^/ratchet/docs/research'},
        {href: 'https://github.com/beyond10x/ratchet', label: 'GitHub', position: 'right'},
      ],
    },
    footer: {
      links: [
        {
          title: 'Documentation',
          items: [
            {label: 'Vision', to: '/docs/'},
            {label: 'Design proposal', to: '/docs/design'},
            {label: 'Research', to: '/docs/research'},
            {label: 'Survey 1: synthesis', to: '/docs/research/synthesis'},
            {label: 'Candidate presets', to: '/docs/research/candidate-presets'},
          ],
        },
        {
          title: 'Project',
          items: [
            {label: 'Source', href: 'https://github.com/beyond10x/ratchet'},
            {label: 'README', href: 'https://github.com/beyond10x/ratchet/blob/main/README.md'},
          ],
        },
      ],
      copyright: 'A beyond10x project · Apache-2.0 · built with Docusaurus and the docs-system product template.',
    },
  } satisfies Preset.ThemeConfig,
};

const site = withProductSite(config, {mark: 'R'});

// withProductSite adds its static directories as absolute paths, which the build would ship in its
// bundle; they are made relative to the site so no machine path reaches the built site.
export default {
  ...site,
  staticDirectories: site.staticDirectories?.map((directory) =>
    directory && path.isAbsolute(directory) ? path.relative(siteDir, directory) : directory,
  ),
} satisfies Config;
