#!/usr/bin/env php
<?php

/*
 * MCP HTTP Calculator Server (Attribute Discovery)
 *
 * This server demonstrates attribute-based discovery for MCP elements
 * (Tools, Resources) using the calculator example, adapted for HTTP transport.
 * It runs via the HTTP transport for deployment on Render.
 *
 * Configured for Render deployment:
 * - Reads PORT from environment variable (Render sets this)
 * - Binds to 0.0.0.0 (required for Render)
 * - Uses StreamableHttpServerTransport for production
 */

declare(strict_types=1);

chdir(__DIR__);
require_once __DIR__ . '/vendor/autoload.php';
require_once __DIR__ . '/examples/01-discovery-stdio-calculator/McpElements.php';

use PhpMcp\Server\Server;
use PhpMcp\Server\Transports\StreamableHttpServerTransport;
use Psr\Log\AbstractLogger;

class StderrLogger extends AbstractLogger
{
    public function log($level, \Stringable|string $message, array $context = []): void
    {
        fwrite(STDERR, sprintf(
            "[%s] %s %s\n",
            strtoupper($level),
            $message,
            empty($context) ? '' : json_encode($context)
        ));
    }
}

try {
    $logger = new StderrLogger();
    $logger->info('Starting MCP HTTP Calculator Server...');

    // Get port from Render environment variable, fallback to 8080 for local dev
    $port = (int) (getenv('PORT') ?: '8080');
    $host = '0.0.0.0'; // Required for Render to route traffic

    $server = Server::make()
        ->withServerInfo('HTTP Calculator', '1.1.0')
        ->withLogger($logger)
        ->build();

    $server->discover(__DIR__ . '/examples/01-discovery-stdio-calculator', ['.']);

    $transport = new StreamableHttpServerTransport($host, $port, 'mcp');

    $server->listen($transport);

    $logger->info('Server listener stopped gracefully.');
    exit(0);

} catch (\Throwable $e) {
    fwrite(STDERR, "[MCP SERVER CRITICAL ERROR]\n");
    fwrite(STDERR, 'Error: ' . $e->getMessage() . "\n");
    fwrite(STDERR, 'File: ' . $e->getFile() . ':' . $e->getLine() . "\n");
    fwrite(STDERR, $e->getTraceAsString() . "\n");
    exit(1);
}
