/* Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and
brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell.
*/

select	MONTH(w.created_at) as monthly_trends,
		count(distinct w.website_session_id) as sessions,
        count(distinct case when w.utm_campaign = 'nonbrand' THEN w.website_session_id ELSE NULL END) as nonbrand_sessions,
        count(distinct case when w.utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END) as nonbrand_orders,
        count(distinct case when w.utm_campaign = 'brand' THEN w.website_session_id ELSE NULL END) as brand_sessions,
        count(distinct case when w.utm_campaign = 'brand' THEN o.order_id ELSE NULL END) as brand_orders
        -- count(distinct o.order_id) as orders,
        -- count(distinct o.order_id)/count(distinct w.website_session_id) as CVR
from	website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
where w.utm_source = 'gsearch' AND w.created_at < '2012-11-27'
group by 1;

/* While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device
type? I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/

select	MONTH(w.created_at) as monthly_trends,
		-- count(distinct w.website_session_id) as sessions,
        count(distinct case when w.device_type = 'desktop' THEN w.website_session_id ELSE NULL END) as desktop_sessions,
        count(distinct case when w.device_type = 'desktop' THEN o.order_id ELSE NULL END) as desktop_orders,
        count(distinct case when w.device_type = 'mobile' THEN w.website_session_id ELSE NULL END) as mobile_sessions,
        count(distinct case when w.device_type = 'mobile' THEN o.order_id ELSE NULL END) as mobile_orders
        -- count(distinct o.order_id) as orders,
        -- count(distinct o.order_id)/count(distinct w.website_session_id) as CVR
from	website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
where w.utm_source = 'gsearch' AND w.created_at < '2012-11-27' AND w.utm_campaign = 'nonbrand'
group by 1;

/* I’m worried that one of our more pessimistic board members may be concerned about the large 
% of traffic from Gsearch. Can you pull monthly trends for Gsearch, alongside monthly trends 
for each of our other channels?
*/

select distinct
		utm_source,
	   utm_campaign,
       http_referer
from website_sessions
where created_at < '2012-11-27';




select	MONTH(w.created_at) as monthly_trends,
        count(distinct case when w.utm_source = 'gsearch' THEN w.website_session_id ELSE NULL END) as gsearch_sessions,
        count(distinct case when w.utm_source = 'bsearch' THEN w.website_session_id ELSE NULL END) as bsearch_sessions,
        count(distinct case when w.utm_source is NULL AND http_referer is NOT NULL THEN w.website_session_id ELSE NULL END) as organic_search_sessions,
        count(distinct case when w.utm_source is NULL AND http_referer is  NULL THEN w.website_session_id ELSE NULL END) as direct_typein_sessions	
from	website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
where w.created_at < '2012-11-27'
group by 1;

/* I’d like to tell the story of our website performance improvements over the course of 
the first 8 months. Could you pull session to order conversion rates, by month?
*/

select	MONTH(w.created_at) as monthly_trends,
        count(distinct w.website_session_id) as sessions,
        count(distinct o.order_id) as orders,
        count(distinct o.order_id)/count(distinct w.website_session_id) as cvr
from	website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
where w.created_at < '2012-11-27'
group by 1;

/*
For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value)
*/

/*
For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each
of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/
DROP temporary table if exists saw_page;
CREATE TEMPORARY TABLE saw_page
select	website_session_id,
		MAX(homepage) as saw_homepage,
        MAX(landerpage) as saw_landerpage,
        -- MAX(products_page) as saw_products_page,
        MAX(fuzzy_page) as saw_fuzzy_page,
        MAX(cart_page) as saw_cart_page,
        MAX(shipping_page) as saw_shipping_page,
        MAX(billing_page) as saw_billing_page,
        MAX(thankyou_page) as saw_thankyou_page
from
(
select	website_sessions.website_session_id,
		website_pageviews.pageview_url,
		case when website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
        case when website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS landerpage,
        -- case when website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
        case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
        case when website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
        case when website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		case when website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		case when website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
from website_pageviews
LEFT JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
where website_pageviews.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
order by 1,2
) as first_page
group by 1;

select	
	case when saw_homepage = 1 THEN 'saw_homepage'
		 when saw_landerpage = 1 THEN 'saw_landerpage'
         ELSE 'CHECK LOGIC'
         END AS segment,
	count(distinct website_session_id) as sessions,
    -- count(case when saw_homepage = 1 THEN website_session_id ELSE NULL END )AS homepage,
    -- count(case when saw_landerpage = 1 THEN website_session_id ELSE NULL END )AS lander,
    -- count(case when saw_products_page = 1 THEN website_session_id ELSE NULL END )AS products,
    count(case when saw_fuzzy_page = 1 THEN website_session_id ELSE NULL END )AS fuzzy,
    count(case when saw_cart_page = 1 THEN website_session_id ELSE NULL END )AS carts,
    count(case when saw_shipping_page = 1 THEN website_session_id ELSE NULL END )AS shippings,
    count(case when saw_billing_page = 1 THEN website_session_id ELSE NULL END )AS billing,
    count(case when saw_thankyou_page = 1 THEN website_session_id ELSE NULL END )AS thankyou
from saw_page
group by 1;

/*
I’d love for you to quantify the impact of our billing test, as well. 
Please analyze the lift generated from the test
 (Sep 10 – Nov 10), in terms of revenue per billing page session, 
 and then pull the number of billing page sessions for the 
 past month to understand monthly impact.
*/

CREATE TEMPORARY TABLE billing_session_lift
select needed_billing,
	   count(distinct website_session_id),
       sum(price_usd)/count(distinct website_session_id) as revenue_per_session
from
(
select	website_pageviews.website_session_id,
		website_pageviews.pageview_url as needed_billing,
        orders.order_id,
        orders.price_usd
from website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
where website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) as billing_table
group by 1;

-- Lift is $8.51(31.33-22.82) per billing-2 session

select	count(website_session_id) as billing_session_past_mth
from website_pageviews
where website_pageviews.pageview_url IN ('/billing', '/billing-2')
AND website_pageviews.created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past mth

-- 1193 billing session past mth
-- lift $8.51/session
-- $10,151 over past mth