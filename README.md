# E-commerce-analytics

This is all about the course project using SQL commands to analyze about the company selling products online.
The following questions has been answered using SQL using MYSQL Workbench platform.

/*
1) First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter 
for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
*/

select	year(w.created_at) yr,
		quarter(w.created_at) qr,
        count(w.website_session_id) as sessions,
        count(o.order_id) as orders
from website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
group by 1,2
order by 1,2;

/* 
2) Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
launched, for session-to-order conversion rate, revenue per order, and revenue per session.
*/

select	YEar(w.created_at) as year,
		Quarter(w.created_at) as qtr,
		count(distinct w.website_session_id) as sessions,
		count(distinct o.order_id) as orders,
        count(distinct o.order_id)/count(distinct w.website_session_id) as session_to_order_cvr,
        SUM(o.price_usd)/count(distinct o.order_id) as revenue_per_order,
        SUM(o.price_usd)/count(distinct w.website_session_id) as revenue_per_session
from	website_sessions w
LEFT JOIN orders o
ON o.website_session_id = w.website_session_id
group by 1,2;

/*
3) I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch
nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

select	year(w.created_at) yr,
		quarter(w.created_at) qtr,
        
        count(distinct case when w.utm_source = 'gsearch' AND w.utm_campaign = 'nonbrand' THEN o.order_id
        ELSE NULL END) as gsearch_nonbrand_orders,
        count(distinct case when w.utm_source = 'bsearch' AND w.utm_campaign = 'nonbrand' THEN o.order_id
        ELSE NULL END) as bsearch_nonbrand_orders,
        count(distinct case when w.utm_campaign = 'brand' THEN o.order_id
        ELSE NULL END) as brand_orders,
        count(distinct case when w.utm_source IS NULL AND w.http_referer IS NOT NULL THEN o.order_id ELSE 
        NULL END) AS organic_search_orders,
        count(distinct case when w.utm_source IS NULL AND w.http_referer IS NULL THEN o.order_id ELSE 
        NULL END) AS direct_type_in_orders
from website_sessions w
LEFT JOIN orders o
ON o.website_session_id = w.website_session_id
group by 1,2;

/* 4) Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. 
Please also make a note of any periods where we made major improvements or optimizations.
*/

select	year(w.created_at) yr,
		quarter(w.created_at) qtr,
        
        count(distinct case when w.utm_source = 'gsearch' AND w.utm_campaign = 'nonbrand' THEN o.order_id
        ELSE NULL END)/count(distinct case when w.utm_source = 'gsearch' AND w.utm_campaign = 'nonbrand' 
        THEN w.website_session_id ELSE NULL END) as cvt_gsearch_nonbrand_orders,
        
        count(distinct case when w.utm_source = 'bsearch' AND w.utm_campaign = 'nonbrand' THEN o.order_id
        ELSE NULL END)/count(distinct case when w.utm_source = 'bsearch' AND w.utm_campaign = 'nonbrand' 
        THEN w.website_session_id ELSE NULL END) as cvt_bsearch_nonbrand_orders,
        
        count(distinct case when w.utm_campaign = 'brand' THEN o.order_id
        ELSE NULL END)/count(distinct case when w.utm_campaign = 'brand' THEN w.website_session_id
        ELSE NULL END) as cvt_brand_orders,
        
        count(distinct case when w.utm_source IS NULL AND w.http_referer IS NOT NULL THEN o.order_id ELSE 
        NULL END) /count(distinct case when w.utm_source IS NULL AND w.http_referer IS NOT NULL THEN w.website_session_id ELSE 
        NULL END) AS cvt_organic_search_orders,
        
        count(distinct case when w.utm_source IS NULL AND w.http_referer IS NULL THEN o.order_id ELSE 
        NULL END)/count(distinct case when w.utm_source IS NULL AND w.http_referer IS NULL THEN w.website_session_id ELSE 
        NULL END) AS cvt_direct_type_in_orders
from website_sessions w
LEFT JOIN orders o
ON o.website_session_id = w.website_session_id
group by 1,2;


/*
5) We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue
 and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
 */
 
select	year(created_at) as yr,
		month(created_at) as mth,
        sum(case when primary_product_id = 1 THEN price_usd ELSE NULL END) as revenue_fuzzy,
        sum(case when primary_product_id = 1 THEN price_usd-cogs_usd ELSE NULL END) as margin_fuzzy,
        sum(case when primary_product_id = 2 THEN price_usd ELSE NULL END) as revenue_lovebear,
        sum(case when primary_product_id = 2 THEN price_usd-cogs_usd ELSE NULL END) as margin_fuzzy,
        sum(case when primary_product_id = 3 THEN price_usd ELSE NULL END) as revenue_birthday_bear,
        sum(case when primary_product_id = 3 THEN price_usd-cogs_usd ELSE NULL END) as margin_birthday_bear,
        sum(case when primary_product_id = 4 THEN price_usd ELSE NULL END) as revenue_flower_bear,
        sum(case when primary_product_id = 4 THEN price_usd-cogs_usd ELSE NULL END) as margin_flower_bear,
        sum(price_usd) as total_sales
from orders
group by 1,2;
        
/* 
6) Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products 
page, and show how the % of those sessions clicking through another page has changed over time, along with a 
view of how conversion from /products to placing an order has improved.
*/

DROP TEMPORARY TABLE IF EXISTS products_pageviews;
CREATE TEMPORARY TABLE products_pageviews

select	year(created_at) as yr,
		month(created_at) as mth,
         website_session_id,
         website_pageview_id
from website_pageviews
where pageview_url = '/products';

select	products_pageviews.yr,
		products_pageviews.mth,
		count(products_pageviews.website_session_id) as sessions,
		count(distinct website_pageviews.website_session_id) as session_beyond_products,
        count(distinct website_pageviews.website_session_id)/count(products_pageviews.website_session_id) as sessions_beyond_cvr,
        count(distinct orders.order_id) as order_sessions,
        count(distinct orders.order_id)/count(products_pageviews.website_session_id) as cvr_orders
from	products_pageviews
LEFT JOIN website_pageviews
ON products_pageviews.website_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
LEFT JOIN orders
ON products_pageviews.website_session_id = orders.website_session_id
group by 1,2;

/*
7) We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell
item). Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/

select	primary_product_id,
		count(distinct orders.order_id) as total_orders,
        count(case when product_id = 1 THEN orders.order_id END) as xsold_prd_1,
        count(case when product_id = 2 THEN orders.order_id END) as xsold_prd_2,
        count(case when order_items.product_id = 3 THEN orders.order_id END) as xsold_prd_3,
        count(case when order_items.product_id = 4 THEN orders.order_id END) as xsold_prd_4,
        count(case when order_items.product_id = 1 THEN orders.order_id END)/count(distinct orders.order_id) as p1_xsell_rt,
        count(case when order_items.product_id = 2 THEN orders.order_id END)/count(distinct orders.order_id) as p2_xsell_rt,
        count(case when order_items.product_id = 3 THEN orders.order_id END)/count(distinct orders.order_id) as p3_xsell_rt,
        count(case when order_items.product_id = 4 THEN orders.order_id END)/count(distinct orders.order_id) as p4_xsell_rt
from orders
LEFT JOIN order_items
ON orders.order_id = order_items.order_id
AND	is_primary_item = 0
where orders.created_at > '2014-12-05'
group by 1;

/*
8) In addition to telling investors about what we’ve already achieved, let’s show them that we still have plenty of 
gas in the tank. Based on all the analysis you’ve done, could you share some recommendations and opportunities for 
us going forward? No right or wrong answer here – I’d just like to hear your perspective!
*/

