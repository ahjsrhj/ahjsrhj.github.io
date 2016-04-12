{%
  set js_vendors = [
  ]
%}

{% if theme.fancybox %}
  {% set js_vendors[js_vendors.length] = 'fancybox/source/jquery.fancybox.pack.js' %}
{% endif %}

{# Reset `window.Promise` when it was not a function. #}
{# IE refers the element whose id is `Promise` as `window.Promise`, this causes Velocity throwing an exception #}
<script type="text/javascript">
  if (Object.prototype.toString.call(window.Promise) !== '[object Function]') {
    window.Promise = null;
  }
</script>
<script type="text/javascript" src="//7xsomm.com2.z0.glb.clouddn.com/index.js?v=2.1.3"></script>
<script type="text/javascript" src="//cdn.bootcss.com/jquery_lazyload/1.9.7/jquery.lazyload.min.js"></script>
<script type="text/javascript" src="//cdn.bootcss.com/fastclick/1.0.6/fastclick.min.js?v=1.0.6"></script>
<script type="text/javascript" src="//cdn.bootcss.com/velocity/1.2.3/velocity.min.js"></script>
<script type="text/javascript" src="//cdn.bootcss.com/velocity/1.2.3/velocity.ui.min.js"></script>


{% for vendor in js_vendors %}
  <script type="text/javascript" src="{{ url_for(theme.vendors) }}/{{ vendor }}"></script>
{% endfor %}
