// High-quality SVG-based sample crop images representing various agricultural conditions.
// These are encoded as SVG data URIs, which are lightweight, robust, and render beautifully.

export const SAMPLE_CROP_IMAGES = [
  {
    id: 'healthy',
    name: 'Optimal Leaf Turgor (Healthy)',
    crop: 'Lettuce / Spinach',
    anomalyType: 'clear',
    description: 'Uniform deep green coloring, robust leaf structure, and no visible biological or chemical stress markers.',
    dataUri: `data:image/svg+xml;utf8,<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="hg" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="%2310b981"/><stop offset="100%" stop-color="%23047857"/></radialGradient></defs><rect width="100%" height="100%" fill="%2308251e"/><circle cx="100" cy="100" r="90" stroke="rgba(16,185,129,0.15)" stroke-width="1" stroke-dasharray="4 4" fill="none"/><path d="M100 25 C130 50 150 90 100 170 C50 90 70 50 100 25 Z" fill="url(%23hg)"/><path d="M100 25 L100 170" stroke="%2334d399" stroke-width="2.5"/><path d="M100 55 Q125 60 135 50 M100 85 Q130 90 140 78 M100 115 Q120 120 128 110" stroke="%2334d399" stroke-width="1.5" fill="none"/><path d="M100 55 Q75 60 65 50 M100 85 Q70 90 60 78 M100 115 Q80 120 72 110" stroke="%2334d399" stroke-width="1.5" fill="none"/><circle cx="125" cy="80" r="3.5" fill="%2338bdf8" opacity="0.8"/><circle cx="75" cy="115" r="2.5" fill="%2338bdf8" opacity="0.7"/></svg>`
  },
  {
    id: 'drought',
    name: 'Severe Leaf Wilting (Drought)',
    crop: 'Grapes / Vines',
    anomalyType: 'drought',
    description: 'Leaf margin curling, yellow-brown discoloration, cracked dry soil background, and severe turgor pressure loss.',
    dataUri: `data:image/svg+xml;utf8,<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="dg" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="%23855b32"/><stop offset="100%" stop-color="%234a3525"/></radialGradient></defs><rect width="100%" height="100%" fill="%232a1a08"/><path d="M20 160 L180 160 M50 160 L80 190 M110 160 L95 185 M150 160 L165 180" stroke="%233a2818" stroke-width="3"/><path d="M100 35 C125 55 138 85 100 155 C62 85 75 55 100 35 Z" fill="url(%23dg)" opacity="0.95"/><path d="M100 35 Q95 85 100 155" stroke="%235a3d1d" stroke-width="2.5" fill="none"/><path d="M100 65 Q120 68 125 60 M100 95 Q118 98 122 90" stroke="%235a3d1d" stroke-width="1.5" fill="none"/><path d="M100 65 Q80 68 75 60 M100 95 Q82 98 78 90" stroke="%235a3d1d" stroke-width="1.5" fill="none"/><path d="M125 60 Q135 70 128 85 M75 60 Q65 70 72 85" stroke="%23b45309" stroke-width="2" fill="none"/><text x="100" y="24" fill="%23f59e0b" font-family="monospace" font-size="10" text-anchor="middle" font-weight="bold">DRY CANOPY WARN</text></svg>`
  },
  {
    id: 'pests',
    name: 'Spider Mites Infestation (Pests)',
    crop: 'Apple Canopy',
    anomalyType: 'pests',
    description: 'Leaf surface necrosis holes, fine web structures on undersides, and clustered red micro-parasite visual markers.',
    dataUri: `data:image/svg+xml;utf8,<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="pg" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="%23059669"/><stop offset="100%" stop-color="%23064e3b"/></radialGradient></defs><rect width="100%" height="100%" fill="%231c1b18"/><path d="M100 25 C130 50 150 90 100 170 C50 90 70 50 100 25 Z" fill="url(%23pg)"/><path d="M100 25 L100 170" stroke="%23047857" stroke-width="2"/><circle cx="70" cy="75" r="7" fill="%231c1b18"/><circle cx="76" cy="71" r="5" fill="%231c1b18"/><circle cx="128" cy="105" r="9" fill="%231c1b18"/><circle cx="120" cy="110" r="6" fill="%231c1b18"/><path d="M55 90 Q65 85 75 95 M120 70 Q130 80 140 68" stroke="rgba(255,255,255,0.25)" stroke-width="1" fill="none"/><circle cx="130" cy="98" r="3" fill="%23ef4444"/><line x1="130" y1="98" x2="134" y2="94" stroke="%23ef4444" stroke-width="1"/><line x1="130" y1="98" x2="126" y2="102" stroke="%23ef4444" stroke-width="1"/><circle cx="68" cy="80" r="3.5" fill="%23ef4444"/><circle cx="85" cy="50" r="3" fill="%23ef4444"/><circle cx="112" cy="120" r="2.5" fill="%23ef4444"/></svg>`
  },
  {
    id: 'disease',
    name: 'Powdery Mildew Coating (Disease)',
    crop: 'Vineyard Leaves',
    anomalyType: 'disease',
    description: 'White talcum-powder circular mycelial patches, chlorotic leaf margins, and cell necrosis tissue drops.',
    dataUri: `data:image/svg+xml;utf8,<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="dg" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="%23047857"/><stop offset="100%" stop-color="%23022c22"/></radialGradient></defs><rect width="100%" height="100%" fill="%23161c24"/><path d="M100 25 C130 50 150 90 100 170 C50 90 70 50 100 25 Z" fill="url(%23dg)"/><path d="M100 25 L100 170" stroke="%2303543d" stroke-width="2"/><circle cx="92" cy="65" r="9" fill="%23ffffff" opacity="0.65"/><circle cx="95" cy="62" r="6" fill="%23ffffff" opacity="0.4"/><circle cx="118" cy="85" r="12" fill="%23ffffff" opacity="0.6"/><circle cx="80" cy="115" r="10" fill="%23ffffff" opacity="0.55"/><circle cx="115" cy="125" r="8" fill="%23ffffff" opacity="0.5"/><circle cx="75" cy="50" r="6" fill="%23ffffff" opacity="0.6"/></svg>`
  },
  {
    id: 'nutrient_def',
    name: 'Severe Chlorosis (NPK Deficit)',
    crop: 'Wheat / Grains',
    anomalyType: 'nutrient_def',
    description: 'Generalized leaf yellowing, interveinal chlorosis (prominent green veins on yellow tissue), and stunted growth.',
    dataUri: `data:image/svg+xml;utf8,<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg"><defs><radialGradient id="ng" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="%23eab308"/><stop offset="100%" stop-color="%23a16207"/></radialGradient></defs><rect width="100%" height="100%" fill="%231d231e"/><path d="M100 25 C130 50 150 90 100 170 C50 90 70 50 100 25 Z" fill="url(%23ng)"/><path d="M100 25 L100 170" stroke="%2315803d" stroke-width="2.5"/><path d="M100 55 Q125 60 135 50 M100 85 Q130 90 140 78 M100 115 Q120 120 128 110" stroke="%2315803d" stroke-width="2" fill="none"/><path d="M100 55 Q75 60 65 50 M100 85 Q70 90 60 78 M100 115 Q80 120 72 110" stroke="%2315803d" stroke-width="2" fill="none"/></svg>`
  }
];
