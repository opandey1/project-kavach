The misleading error wording. Docker said "failed to resolve reference" — which sounds like a registry / image-not-found problem, but the root cause was three lines down in the stack trace. The lesson: always read Docker errors bottom-up.
The VirtualBox NAT-DNS gotcha. This bites a lot of people doing security work in VMs and is exactly the kind of environment friction the engagement is supposed to surface.

VirtualBox NAT DNS proxy timed out on Docker registry lookups; fixed by overriding Docker daemon DNS in `/etc/docker/daemon.json`. Image-pull errors with 'failed to resolve reference' wording can be DNS issues rather than registry-side problems — read the last line of the error first.
