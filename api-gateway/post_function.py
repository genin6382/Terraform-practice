import json
def lambda_handler(event, context):
    try:
        message = "Hello" + event['student_name'] + "!" + "what is the temperature in " + event['city'] + "?"
        return {
            'statusCode': 200,
            'body': json.dumps(message)
        }
    except:
        return {
            'statusCode': 400,
            'body': json.dumps('Bad Request')
        }