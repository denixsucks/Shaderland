using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] private float movementSpeed;
    [SerializeField] private float sprintMultiplier;
    [SerializeField] private float jumpForce;

    private bool _canJump;
    private float _distToGround;
    private Rigidbody _rigidbody;

    private void Awake()
    {
        CapsuleCollider capsuleCollider = GetComponentInChildren<CapsuleCollider>();
        _distToGround = capsuleCollider.bounds.extents.y;
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        _canJump = isGrounded;
        Sprint(sprintMultiplier);
        Jump(jumpForce, _canJump);
        Move();
    }

    // Move
    private void Move()
    {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");
        Vector3 movement = transform.right * horizontal + transform.forward * vertical;
        _rigidbody.velocity = movement * movementSpeed + Vector3.up * _rigidbody.velocity.y;
    }

    // Sprint
    private void Sprint(float multiplier)
    {
        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            movementSpeed *= multiplier;
        }
        else if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            movementSpeed /= multiplier;
        }
    }

    // Jump
    private void Jump(float force, bool canJump)
    {
        //Jump!
        if (Input.GetKeyDown(KeyCode.Space) && canJump)
        {
            _rigidbody.AddForce(new Vector3(0,force,0),ForceMode.Impulse);
        }
    }
    bool isGrounded => Physics.Raycast(transform.position, -Vector3.up, _distToGround + 0.1f);
}
