import boto3
import logging
import json
import cfnresponse

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SUCCESS = "SUCCESS"
FAILED = "FAILED"


def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event))

    try:
        
        # Set up clients
        workmail = boto3.client('workmail')
        secrets_manager = boto3.client('secretsmanager')
        ssm = boto3.client('ssm')

        # Set variables used for both Create and Delete requests
        user_name = event['ResourceProperties']['UserName']
        domain = event['ResourceProperties']['Domain']

        # Retrieve org_id if there is an org with matching domain

        org_response = workmail.list_organizations()
        all_orgs = org_response.get('OrganizationSummaries', [])
        org_id = [org['OrganizationId'] for org in all_orgs if org['DefaultMailDomain'] == domain].pop(0)
        

        if event['RequestType'] == 'Create':
            logger.info('Create was triggered')
            email = f"{user_name}@{domain}"
            aliases = event['ResourceProperties'].get('Aliases', [])
            secret_name = event['ResourceProperties']['SecretName']

            # Get password from secrets manager
            sm_response = secrets_manager.get_secret_value(SecretId=secret_name)
            pw = sm_response['SecretString']

            info = f'sm_response: {sm_response}\npw: {pw}\nemail: {email}\naliases: {aliases}'
            logger.info(info)

            # Create the WorkMail user
            wm_response = workmail.create_user(
                OrganizationId=org_id,
                Name=user_name,
                DisplayName=user_name,
                Password=pw
            )
            
            logger.info(f'wm_response: {json.dumps(wm_response)}')
            
            user_id = wm_response['UserId']
            
            # Register the user to the domain
            reg_response = workmail.register_to_work_mail(
                OrganizationId=org_id,
                EntityId=user_id,
                Email=email
            )
            
            logger.info(f'reg_response: {json.dumps(reg_response)}')
            
            
            # Create aliases for the user
            for alias in aliases:
                alias_response = workmail.create_alias(
                    OrganizationId=org_id,
                    EntityId=user_id,
                    Alias=f"{alias}.{user_name}@{domain}"
                )
                logger.info(json.dumps(alias_response, default=str))

        if event['RequestType'] == 'Delete':
            logger.info('Delete was triggered')
            email = f"{user_name}@{domain}"
            user_id = ""

            # Get users
            users_response = workmail.list_users(
                OrganizationId=org_id,
            )

            logger.info(f'users_response: {json.dumps(users_response, default=str)}')

            users = users_response.get('Users', [])

            # Find user by email, if yes, return id
            for user in users:
                if user.get('Email') == email:
                    user_id = user.get('Id')

            if len(user_id) > 0:
                
                # Delete aliases
                aliases_response = workmail.list_aliases(
                    OrganizationId=org_id,
                    EntityId=user_id
                )
                for alias in aliases_response['Aliases']:
                    if alias != email:
                        workmail.delete_alias(
                            OrganizationId=org_id,
                            EntityId=user_id,
                            Alias=alias
                        )

                # Deregister User from WorkMail
                dereg_response = workmail.deregister_from_work_mail(
                    OrganizationId=org_id,
                    EntityId=user_id
                )

                logger.info(json.dumps(dereg_response, default=str))

                # Delete the WorkMail user
                del_response = workmail.delete_user(
                    OrganizationId=org_id,
                    UserId=user_id
                )

                logger.info(json.dumps(del_response, default=str))
                

    except Exception as e:
        cfnresponse.send(event, context, FAILED, {}, str(e))
        return

    cfnresponse.send(event, context, SUCCESS, {})