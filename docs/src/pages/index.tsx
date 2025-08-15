import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';

import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <div className={styles.logoContainer}>
          <img 
            src="img/yippy-banner.png" 
            alt="Yippy Framework Banner" 
            className={styles.heroLogo}
          />
        </div>
        <Heading as="h1" className="hero__title">
          Yippy Framework
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
                       <div className={styles.buttons}>
                 <Link
                   className="button button--primary button--lg"
                   to="/docs/about">
                   Get Started →
                 </Link>
                 <Link
                   className="button button--secondary button--lg"
                   to="/api">
                   View API
                 </Link>
               </div>
        <div className={styles.stats}>
          <div className={styles.stat}>
            <strong>20+</strong>
            <span>Built-in Modules</span>
          </div>
          <div className={styles.stat}>
            <strong>v1.2</strong>
            <span>Latest Release</span>
          </div>
          <div className={styles.stat}>
            <strong>Active</strong>
            <span>In Development</span>
          </div>
        </div>
        <div className={styles.floatingElements}>
          <div className={styles.floatingElement}></div>
          <div className={styles.floatingElement}></div>
          <div className={styles.floatingElement}></div>
        </div>
      </div>
    </header>
  );
}

function FeatureSpotlight() {
  const features = [
    {
      icon: "⚡",
      title: "Rapid Prototyping",
      description: "Skip the boilerplate. Everything pre-built to create games fast without reinventing basic systems",
      gradient: "from-yellow-400 to-orange-500"
    },
    {
      icon: "🎮",
      title: "Complete Game Framework",
      description: "Ragdoll physics, marketplace system, datastore management, UI toolkit - all integrated and ready",
      gradient: "from-blue-400 to-purple-500"
    },
    {
      icon: "🚀",
      title: "Team-Optimized",
      description: "Purpose-built for YippyGames development workflow with consistent patterns and standards",
      gradient: "from-green-400 to-cyan-500"
    },
    {
      icon: "🔧",
      title: "Production-Ready Systems",
      description: "20+ built-in modules including networking, UI animations, and developer tools that save weeks of work",
      gradient: "from-pink-400 to-red-500"
    }
  ];

  return (
    <section className={styles.featureSpotlight}>
      <div className="container">
        <div className={styles.spotlightHeader}>
          <Heading as="h2" className={styles.sectionTitle}>
            Built for Speed, Not Complexity
          </Heading>
          <p className={styles.sectionDescription}>
            Everything you need to create games fast. No more spending weeks building basic systems.
          </p>
        </div>
        <div className={styles.spotlightGrid}>
          {features.map((feature, idx) => (
            <div key={idx} className={styles.spotlightCard}>
              <div className={styles.spotlightIcon}>
                {feature.icon}
              </div>
              <h3 className={styles.spotlightTitle}>{feature.title}</h3>
              <p className={styles.spotlightDescription}>{feature.description}</p>
              <div className={styles.spotlightGlow}></div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function QuickStartSection() {
  return (
    <section className={styles.quickStart}>
      <div className="container">
        <div className="row">
          <div className="col col--6">
            <div className={styles.quickStartContent}>
              <Heading as="h2" className={styles.sectionTitle}>
                Ready to Build?
              </Heading>
              <p className={styles.sectionDescription}>
                Jump straight into game development with everything ready to go. 
                Spend time on your game ideas, not rebuilding the same systems over and over.
              </p>
              <div className={styles.quickStartButtons}>
                <Link
                  className="button button--primary button--lg"
                  to="/docs/about">
                  Quick Start Guide
                </Link>
              </div>
            </div>
          </div>
          <div className="col col--6">
            <div className={styles.codePreview}>
              <div className={styles.codeHeader}>
                <span className={styles.codeLang}>lua</span>
                <span className={styles.codeTitle}>example.lua</span>
              </div>
              <pre className={styles.codeBlock}>
                <code className="language-lua">{`local PlayerController = Framework.CreateController({
    Name = "PlayerController"
})

function PlayerController:Start()
    -- Listen for data changes
    Framework.BuiltInClient.Datastore:Listen({
        path = "PlayerProfile/Coins"
    }, function(event)
        Framework.BuiltInClient.Notifications:Create("Success", "Coins updated!")
    end)
end

return PlayerController`}</code>
              </pre>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - Lightweight Roblox Framework`}
      description="A powerful, modular framework for Roblox game development with built-in modules, services, and utilities.">
      <HomepageHeader />
      <main>
        <FeatureSpotlight />
        <QuickStartSection />
      </main>
    </Layout>
  );
}
