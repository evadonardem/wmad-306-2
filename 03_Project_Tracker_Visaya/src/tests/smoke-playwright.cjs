const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  const base = process.env.BASE_URL || 'http://host.docker.internal:8000';
  try {
    console.log('Visiting login page...');
    await page.goto(`${base}/login`, { waitUntil: 'networkidle' });
    await page.waitForSelector('input[name="email"]', { timeout: 10000 });

    // capture console errors
    let consoleErrors = [];
    page.on('console', (msg) => {
      try {
        if (msg.type && msg.type() === 'error') consoleErrors.push(msg.text());
      } catch (e) {}
    });

    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password');
    // click the submit button and wait for navigation
    await Promise.all([
      page.waitForNavigation({ waitUntil: 'networkidle', timeout: 5000 }).catch(()=>{}),
      page.click('button[type="submit"]').catch(()=>{}),
    ]);
    await page.waitForTimeout(1000);

    console.log('Navigating to /app/projects');
    await page.goto(`${base}/app/projects`, { waitUntil: 'networkidle' });
    const projectsVisible = await page.locator('text=Projects').first().isVisible().catch(()=>false);
    if (!projectsVisible) {
      console.error('Projects page did not render expected content.');
      await page.screenshot({ path: 'projects-failure.png' }).catch(()=>{});
      await browser.close();
      process.exit(2);
    }

    console.log('Navigating to /app/tasks');
    await page.goto(`${base}/app/tasks`, { waitUntil: 'networkidle' });
    const tasksVisible = await page.locator('text=Tasks').first().isVisible().catch(()=>false);
    if (!tasksVisible) {
      console.error('Tasks page did not render expected content.');
      await page.screenshot({ path: 'tasks-failure.png' }).catch(()=>{});
      await browser.close();
      process.exit(3);
    }

    await page.screenshot({ path: 'smoke-success.png' }).catch(()=>{});
    if (consoleErrors.length) {
      console.error('Console errors detected:', consoleErrors.slice(0,5));
      await page.screenshot({ path: 'smoke-console-errors.png' }).catch(()=>{});
      await browser.close();
      process.exit(4);
    }
    console.log('SMOKE:OK');
    await browser.close();
    process.exit(0);
  } catch (err) {
    console.error('Error during smoke:', err);
    await page.screenshot({ path: 'smoke-error.png' }).catch(()=>{});
    await browser.close();
    process.exit(1);
  }
})();
