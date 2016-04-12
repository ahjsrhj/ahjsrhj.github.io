
{# Reset `window.Promise` when it was not a function. #}
{# IE refers the element whose id is `Promise` as `window.Promise`, this causes Velocity throwing an exception #}
<script type="text/javascript">
  if (Object.prototype.toString.call(window.Promise) !== '[object Function]') {
    window.Promise = null;
  }
</script>

<script type="text/javascript" src="{{ url_for(theme.vendors) }}/jquery/index.js?__inline=true"></script>
<script type="text/javascript" src="//cdn.bootcss.com/jquery_lazyload/1.9.7/jquery.lazyload.min.js?__inline=true"></script>
<script type="text/javascript" src="//cdn.bootcss.com/fastclick/1.0.6/fastclick.min.js?__inline=true"></script>
<script type="text/javascript" src="//cdn.bootcss.com/velocity/1.2.3/velocity.min.js?__inline=true"></script>
<script type="text/javascript" src="//cdn.bootcss.com/velocity/1.2.3/velocity.ui.min.js?__inline=true"></script>
<script type="text/javascript" src="//cdn.bootcss.com/fancybox/2.1.4/jquery.fancybox.pack.min.js?__inline=true"></script>
