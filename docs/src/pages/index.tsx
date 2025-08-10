import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          🚀 {siteConfig.title}
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--primary button--lg"
            to="/docs/intro">
            Get Started 🎮
          </Link>
          <Link
            className="button button--secondary button--lg"
            to="/docs/examples">
            View Examples 📚
          </Link>
        </div>
        <div className={styles.stats}>
          <div className={styles.stat}>
            <strong>15+</strong>
            <span>Built-in Modules</span>
          </div>
          <div className={styles.stat}>
            <strong>v1.1</strong>
            <span>Alpha Release</span>
          </div>
          <div className={styles.stat}>
            <strong>100%</strong>
            <span>Free & Open Source</span>
          </div>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - Roblox Framework`}
      description="A powerful, modular framework for Roblox game development with built-in modules, services, and utilities.">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
