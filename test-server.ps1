# MCP Server Test Script
# Tests the calculator server functionality

# Setup
$headers = @{"Accept"="application/json, text/event-stream"; "Content-Type"="application/json"}

# $baseUrl = "http://localhost:8080/mcp"
$baseUrl = "https://server-7mdk.onrender.com/mcp" 

Write-Host "=== MCP Server Test Suite ===" -ForegroundColor Cyan
Write-Host ""

# 1. Initialize and get session ID
Write-Host "1. Initializing..." -ForegroundColor Cyan
try {
    $initBody = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
    $initResponse = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $initBody -UseBasicParsing
    $sessionId = $initResponse.Headers['Mcp-Session-Id']
    $headers['Mcp-Session-Id'] = $sessionId
    Write-Host "   [OK] Session ID: $sessionId" -ForegroundColor Green
    $initResult = $initResponse.Content | ConvertFrom-Json
    Write-Host "   [OK] Server: $($initResult.result.serverInfo.name) v$($initResult.result.serverInfo.version)" -ForegroundColor Green
    
    # Send initialized notification to complete handshake
    $initializedBody = '{"jsonrpc":"2.0","method":"notifications/initialized"}'
    Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $initializedBody -UseBasicParsing | Out-Null
    Write-Host "   [OK] Initialized notification sent" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
    exit 1
}

# 2. List Tools
Write-Host "`n2. Listing tools..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Found $($result.result.tools.Count) tool(s)" -ForegroundColor Green
    foreach ($tool in $result.result.tools) {
        Write-Host "     - $($tool.name): $($tool.description)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 3. Call Calculate (Add)
Write-Host "`n3. Calculating: 10 + 5..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"calculate","arguments":{"a":10,"b":5,"operation":"add"}}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Result: $($result.result.content[0].text)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
    Write-Host "   Response: $($_.Exception.Response)" -ForegroundColor Red
}

# 4. Call Calculate (Multiply)
Write-Host "`n4. Calculating: 7 * 8..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"calculate","arguments":{"a":7,"b":8,"operation":"multiply"}}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Result: $($result.result.content[0].text)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 5. Call Calculate (Divide)
Write-Host "`n5. Calculating: 100 / 4..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"calculate","arguments":{"a":100,"b":4,"operation":"divide"}}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Result: $($result.result.content[0].text)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 6. List Resources
Write-Host "`n6. Listing resources..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":6,"method":"resources/list","params":{}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Found $($result.result.resources.Count) resource(s)" -ForegroundColor Green
    foreach ($resource in $result.result.resources) {
        Write-Host "     - $($resource.uri): $($resource.name)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 7. Read Config
Write-Host "`n7. Reading calculator config..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":7,"method":"resources/read","params":{"uri":"config://calculator/settings"}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    $config = $result.result.contents[0].text | ConvertFrom-Json
    Write-Host "   [OK] Config: precision=$($config.precision), allow_negative=$($config.allow_negative)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 8. Update Precision
Write-Host "`n8. Updating precision to 5..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":8,"method":"tools/call","params":{"name":"update_setting","arguments":{"setting":"precision","value":5}}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    $responseData = $result.result.content[0].text | ConvertFrom-Json
    Write-Host "   [OK] $($responseData.message)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 9. Verify Config Changed
Write-Host "`n9. Verifying config changed..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":9,"method":"resources/read","params":{"uri":"config://calculator/settings"}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    $config = $result.result.contents[0].text | ConvertFrom-Json
    Write-Host "   [OK] Config: precision=$($config.precision), allow_negative=$($config.allow_negative)" -ForegroundColor Green
    if ($config.precision -eq 5) {
        Write-Host "   [OK] Precision successfully updated!" -ForegroundColor Green
    } else {
        Write-Host "   [FAIL] Precision was not updated (expected 5, got $($config.precision))" -ForegroundColor Red
    }
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

# 10. Calculate with new precision
Write-Host "`n10. Calculating 10/3 with new precision..." -ForegroundColor Cyan
try {
    $body = '{"jsonrpc":"2.0","id":10,"method":"tools/call","params":{"name":"calculate","arguments":{"a":10,"b":3,"operation":"divide"}}}'
    $response = Invoke-WebRequest -Uri $baseUrl -Method POST -Headers $headers -Body $body -UseBasicParsing
    $result = $response.Content | ConvertFrom-Json
    Write-Host "   [OK] Result: $($result.result.content[0].text)" -ForegroundColor Green
} catch {
    Write-Host "   [FAIL] Failed: $_" -ForegroundColor Red
}

Write-Host "`n=== Test Suite Complete ===" -ForegroundColor Cyan
