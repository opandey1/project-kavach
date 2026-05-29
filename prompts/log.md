Lessons Learned:
1.) The misleading error wording. Docker said "failed to resolve reference" — which sounds like a registry / image-not-found problem, but the root cause was three lines down in the stack trace. The lesson: always read Docker errors bottom-up.
The VirtualBox NAT-DNS gotcha. This bites a lot of people doing security work in VMs and is exactly the kind of environment friction the engagement is supposed to surface.

VirtualBox NAT DNS proxy timed out on Docker registry lookups; fixed by overriding Docker daemon DNS in `/etc/docker/daemon.json`. Image-pull errors with 'failed to resolve reference' wording can be DNS issues rather than registry-side problems — read the last line of the error first.

2.) Initial healthcheck on DVWA using wget --spider http://localhost/login.php returned unhealthy indefinitely. Two-part lesson: (1) (unhealthy) ≠ broken container — the app worked fine via browser; (2) DVWA can't be HTTP-healthchecked before the manual DB init, so the cleanest fix was to drop the check rather than work around the chicken-and-egg problem. Kept the Juice Shop healthcheck which worked first time.
