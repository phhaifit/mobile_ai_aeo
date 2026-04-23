export const isProduction = () => process.env.NODE_ENV === 'production';

export const useIPApproachForN8n = () => process.env.N8N_STRATEGY === 'IP';
