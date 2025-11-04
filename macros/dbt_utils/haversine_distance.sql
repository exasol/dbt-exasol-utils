{% macro exasol__haversine_distance(lat1, lon1, lat2, lon2, unit='mi') -%}
{%- if unit == 'mi' %}
    {% set conversion_rate = 1 %}
{% elif unit == 'km' %}
    {% set conversion_rate = 1.60934 %}
{% else %}
    {{ exceptions.raise_compiler_error("unit input must be one of 'mi' or 'km'. Got " ~ unit) }}
{% endif %}

    2 * 3961 * asin(sqrt(power((sin(radians(({{ lat2 }} - {{ lat1 }}) / 2))), 2) +
    cos(radians({{lat1}})) * cos(radians({{lat2}})) *
    power((sin(radians(({{ lon2 }} - {{ lon1 }}) / 2))), 2))) * {{ conversion_rate }}

{%- endmacro %}
