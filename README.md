# LoadBalancer_backend_change
In case you need to remove a worker from the load balancer for doing some maintenance on it

<pre>
<code>
./lb-backend.ps1 remove|add your-rg your-lb your-vm
</code>
</pre>

or
<pre>
<code>
./lb-backend-change.sh -o remove|add -g your-rg -l your-lb -n your-vm
</code>
</pre>
