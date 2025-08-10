import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  icon: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: '🚀 Fast Development',
    icon: '⚡',
    description: (
      <>
        Pre-built modules for common game systems like UI, camera controls, 
        data storage, and animations. Get your game up and running in minutes, 
        not hours.
      </>
    ),
  },
  {
    title: '🏗️ Modular Architecture',
    icon: '🧩',
    description: (
      <>
        Use only what you need. Enable or disable modules based on your game's 
        requirements. Clean separation between <code>Services</code> and 
        <code>Controllers</code>.
      </>
    ),
  },
  {
    title: '🔧 Developer Tools',
    icon: '🛠️',
    description: (
      <>
        Built-in debugging, command system (Cmdr), VS Code snippets, and 
        comprehensive logging. Everything you need for efficient development.
      </>
    ),
  },
  {
    title: '📱 Cross-Platform',
    icon: '📲',
    description: (
      <>
        Works seamlessly across all Roblox platforms - PC, mobile, Xbox, and VR. 
        Responsive UI components and input handling for all devices.
      </>
    ),
  },
  {
    title: '🔒 Data Safety',
    icon: '💾',
    description: (
      <>
        Robust data storage with ProfileService integration. Session locking, 
        auto-save, and data validation to keep your players' progress safe.
      </>
    ),
  },
  {
    title: '🎨 Modern UI',
    icon: '✨',
    description: (
      <>
        Beautiful notification systems, modern UI components, and smooth 
        animations. Create polished interfaces that your players will love.
      </>
    ),
  },
];

function Feature({title, icon, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className={styles.featureCard}>
        <div className={styles.featureIcon}>
          {icon}
        </div>
        <div className="padding-horiz--md">
          <Heading as="h3" className={styles.featureTitle}>{title}</Heading>
          <p className={styles.featureDescription}>{description}</p>
        </div>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
