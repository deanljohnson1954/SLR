// Wrapper to set NODIST_PREFIX before Astro starts
process.env.NODIST_PREFIX = process.env.NODIST_PREFIX || 'C:\\Program Files (x86)\\Nodist';

// Import and run the Astro CLI
await import('./node_modules/astro/astro.js');
