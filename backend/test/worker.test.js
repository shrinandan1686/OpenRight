import { env, createExecutionContext, waitOnExecutionContext, SELF } from 'cloudflare:test';
import { describe, it, expect, beforeEach } from 'vitest';
import worker from '../worker.js';

describe('OpenRight Worker', () => {
    describe('POST /api/shorten', () => {
        it('should shorten valid YouTube URL', async () => {
            const request = new Request('http://localhost/api/shorten', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: 'https://youtube.com/watch?v=dQw4w9WgXcQ' }),
            });

            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(200);
            const data = await response.json();
            expect(data.shortUrl).toBeDefined();
            expect(data.shortCode).toBeDefined();
            expect(data.shortCode).toHaveLength(6);
        });

        it('should reject invalid YouTube URL', async () => {
            const request = new Request('http://localhost/api/shorten', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: 'https://google.com' }),
            });

            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(400);
            const data = await response.json();
            expect(data.error).toContain('Invalid YouTube URL');
        });

        it('should reject missing URL', async () => {
            const request = new Request('http://localhost/api/shorten', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({}),
            });

            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(400);
            const data = await response.json();
            expect(data.error).toContain('URL is required');
        });

        it('should enforce rate limiting', async () => {
            const testIp = '192.168.1.100';
            const requests = [];

            // Make 11 requests (limit is 10)
            for (let i = 0; i < 11; i++) {
                const request = new Request('http://localhost/api/shorten', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'CF-Connecting-IP': testIp,
                    },
                    body: JSON.stringify({ url: `https://youtube.com/watch?v=test00000${i}` }),
                });

                const ctx = createExecutionContext();
                const response = await worker.fetch(request, env, ctx);
                await waitOnExecutionContext(ctx);
                requests.push(response);
            }

            // First 10 should succeed
            for (let i = 0; i < 10; i++) {
                expect(requests[i].status).toBe(200);
            }

            // 11th should be rate limited
            expect(requests[10].status).toBe(429);
            const data = await requests[10].json();
            expect(data.error).toContain('Rate limit exceeded');
        });
    });

    describe('GET /:shortCode', () => {
        it('should redirect to YouTube with valid short code', async () => {
            // First create a short link
            const createRequest = new Request('http://localhost/api/shorten', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url: 'https://youtube.com/watch?v=dQw4w9WgXcQ' }),
            });

            const createCtx = createExecutionContext();
            const createResponse = await worker.fetch(createRequest, env, createCtx);
            await waitOnExecutionContext(createCtx);

            const { shortCode } = await createResponse.json();

            // Now test redirect
            const redirectRequest = new Request(`http://localhost/${shortCode}`);
            const redirectCtx = createExecutionContext();
            const redirectResponse = await worker.fetch(redirectRequest, env, redirectCtx);
            await waitOnExecutionContext(redirectCtx);

            expect(redirectResponse.status).toBe(200);
            expect(redirectResponse.headers.get('Content-Type')).toBe('text/html');

            const html = await redirectResponse.text();
            expect(html).toContain('Opening YouTube');
            expect(html).toContain('dQw4w9WgXcQ');
        });

        it('should return 404 for non-existent short code', async () => {
            const request = new Request('http://localhost/invalid');
            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(404);
        });
    });

    describe('POST /api/analytics', () => {
        it('should accept analytics events', async () => {
            const request = new Request('http://localhost/api/analytics', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    event: 'link_created',
                    data: { shortCode: 'test123' },
                }),
            });

            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(200);
        });
    });

    describe('OPTIONS requests (CORS)', () => {
        it('should handle preflight requests', async () => {
            const request = new Request('http://localhost/api/shorten', {
                method: 'OPTIONS',
            });

            const ctx = createExecutionContext();
            const response = await worker.fetch(request, env, ctx);
            await waitOnExecutionContext(ctx);

            expect(response.status).toBe(200);
            expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
            expect(response.headers.get('Access-Control-Allow-Methods')).toContain('POST');
        });
    });
});
