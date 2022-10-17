# A collection of SQL queries for InsightVM

This repository is intended to serve as a place to store and share SQL queries for use in InsightVM. These queries are sorted into two separate folders based on their use with the reporting data model, versus the data warehouse.

## Navigating This Repo

Navigate to the `sql-query-export` or `data-warehouse-sql-queries` folders to browse the available queries. If you're unsure what a query does based on its title, simply click on the title to see the full query, along with its description at the very top.

If you'd like to use a particular query, simply copy the query text that falls after the `Copy the SQL query below` instructions in the `.sql` file.

## Reporting Data Model

The Reporting Data Model is a dimensional model that allows customized reporting in InsightVM using the PostgreSQL relational database management system. To view the schema for this model, check out our documentation for both facts and dimensions.

https://docs.rapid7.com/insightvm/understanding-the-reporting-data-model-facts/
https://docs.rapid7.com/insightvm/understanding-the-reporting-data-model-dimensions

## Data Warehouse

There is also the option of configuring the Security Console to export data into an external Data Warehouse. This allows for a richer dataset and improved ability to integrate with other internal reporting systems. To learn more about configuring the Data Warehouse, as well as its schema, check out the resources below.

https://docs.rapid7.com/insightvm/configuring-data-warehousing-settings/
https://help.rapid7.com/nexpose/en-us/warehouse/warehouse-schema.html
